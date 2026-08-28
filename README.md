<p align="center">
  <img src="app/assets/images/homenu_logo.png" alt="HomeNu" width="120">
</p>

<h1 align="center">HomeNu</h1>

<p align="center">
  <em>Cooking with what you already have.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Ruby-3.3.5-CC342D" alt="Ruby 3.3.5">
  <img src="https://img.shields.io/badge/Rails-8.1-D30001" alt="Rails 8.1">
  <img src="https://img.shields.io/badge/PostgreSQL-blue" alt="PostgreSQL">
  <img src="https://github.com/MTAdrien/homenu/actions/workflows/ci.yml/badge.svg" alt="CI">
</p>

---

## Table des matières

- [À propos](#à-propos)
- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [L'IA dans HomeNu](#lia-dans-homenu)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Tests et qualité](#tests-et-qualité)
- [Déploiement](#déploiement)
- [Structure du projet](#structure-du-projet)
- [Contribuer](#contribuer)

---

## À propos

**HomeNu** répond à une question quotidienne : *« qu'est-ce qu'on mange ce soir avec ce qu'il reste
dans le frigo ? »*

L'application permet à un foyer de tenir l'inventaire de son frigo, puis de demander à un assistant
IA des recettes construites **uniquement** à partir des ingrédients réellement disponibles, avec des
quantités adaptées au nombre de personnes à table. L'objectif : réduire le gaspillage alimentaire et
la charge mentale des repas.

L'interface est pensée mobile-first (navigation par barre inférieure : Home / Fridge / Assistant).

Projet réalisé dans le cadre du bootcamp **Le Wagon**.

## Fonctionnalités

- 🏠 **Foyer** — création d'un foyer, ajout de membres avec rôle (`Admin` / `Member`) et avatars
- 🧊 **Frigo** — ajout, édition et suppression d'aliments avec quantité et date de péremption
  (mise à jour en place via Turbo Streams)
- ✨ **Suggestion instantanée** — un bouton « Next Meal » qui génère une recette à partir du frigo,
  sans avoir à écrire de message
- 💬 **Assistant conversationnel** — chat avec historique, réponses **streamées token par token**,
  recettes rendues en Markdown
- 📚 **Historique des recettes** — chaque conversation est automatiquement renommée avec le titre de
  la recette proposée
- 🔐 **Authentification** — inscription, connexion et réinitialisation de mot de passe (Devise)

## Stack technique

### Backend

| Composant | Choix |
|---|---|
| Langage | Ruby 3.3.5 |
| Framework | Rails 8.1 |
| Base de données | PostgreSQL |
| Serveur | Puma (+ Thruster) |
| Authentification | Devise |
| Cache / Jobs / WebSockets | Solid Cache, Solid Queue, Solid Cable (Redis en production pour Action Cable) |

### Frontend

| Composant | Choix |
|---|---|
| Rendu | ERB côté serveur |
| Interactivité | Hotwire — Turbo Drive & Turbo Streams |
| JavaScript | Importmap (aucun bundler Node, pas de `package.json`) |
| Assets | Sprockets + SassC |
| UI | Bootstrap 5.3, Simple Form, Font Awesome |
| Médias | Cloudinary |

### IA

| Composant | Choix |
|---|---|
| Client LLM | [`ruby_llm`](https://rubyllm.com) 1.2 |
| Fournisseur | OpenAI |
| Modèle | `gpt-4.1-nano` (défaut de `ruby_llm`) |
| Rendu des réponses | Redcarpet + `sanitize` (liste blanche de balises) |

### Outillage

RuboCop (`rails-omakase`), Brakeman, bundler-audit, Minitest, Capybara + Selenium, GitHub Actions,
Dependabot.

## L'IA dans HomeNu

L'IA n'est pas un gadget branché sur le côté : elle est le cœur du produit. Voici précisément
comment elle est intégrée.

### 1. Un assistant outillé (*tool calling*)

Le modèle n'invente pas le contenu du frigo — il va le **lire** en base via des outils
`RubyLLM::Tool` exposés dans `app/tools/` :

| Outil | Rôle |
|---|---|
| `FridgeInventoryTool` | Renvoie les aliments du foyer : nom, quantité, date de péremption |
| `HouseholdMembersTool` | Renvoie le nombre de membres du foyer |

> **Choix de conception — cloisonnement des données**
> Le `household` est **injecté dans le constructeur de l'outil**, jamais déclaré comme paramètre
> exposé au modèle. Le LLM ne peut donc pas choisir quel foyer consulter : c'est l'application qui
> décide, à partir de l'utilisateur authentifié. Tout nouvel outil doit respecter cette règle.

```ruby
class FridgeInventoryTool < RubyLLM::Tool
  description "Returns the items currently available in the household fridge."

  def initialize(household:)
    @household = household
  end

  def execute
    items = @household.fridge_items
    return "The fridge is empty." if items.empty?

    items.map { |i| { name: i.name, quantity: i.quantity, expiry_date: i.expiry_date } }
  end
end
```

### 2. Un prompt système contraint

`MessagesController::SYSTEM_PROMPT` définit la persona (« HomeNu, a family cooking assistant »),
impose l'appel aux outils avant de répondre, interdit explicitement d'inventer des ingrédients, et
fixe un **format Markdown strict** :

```
## Titre de la recette

**Preparation time:** … **Cooking time:** … **Servings:** …

### Ingredients
- …

### Preparation
1. …
```

Ce format est exploité par `Chat#generate_title_from_recipe`, qui extrait la ligne `## ` pour
renommer automatiquement la conversation. Le prompt n'est donc pas seulement stylistique : c'est un
contrat d'interface entre le modèle et l'application.

### 3. Une réponse streamée en temps réel

`MessagesController#ask_llm` reconstruit l'historique de la conversation depuis PostgreSQL, branche
les outils, puis consomme la réponse **par chunks**. Chaque fragment met à jour le message assistant
et est rediffusé au navigateur via Action Cable :

```ruby
@ruby_llm_chat.ask(@message.content) do |chunk|
  next if chunk.content.blank?

  @assistant_message.content += chunk.content
  broadcast_replace(@assistant_message)
end
```

Côté vue, un simple `turbo_stream_from @chat` suffit : le texte s'écrit progressivement, sans une
ligne de JavaScript personnalisé.

### 4. Un raccourci « zéro saisie »

Le bouton **Next Meal** de la page d'accueil (`ChatsController#create` avec `auto_recipe`) crée une
conversation, y injecte un message utilisateur pré-rempli, appelle le modèle et redirige directement
vers la recette obtenue.

### 5. Garde-fous

- **Sortie assainie** : le Markdown généré passe par Redcarpet (`filter_html: true`) puis par
  `sanitize` sur une liste blanche (`h1 h2 h3 p strong em ul ol li br`) — le HTML produit par le
  modèle ne peut pas injecter de script.
- **Périmètre des données** : le modèle n'accède qu'aux données du foyer courant, via les outils.
- **Clé API** : `OPENAI_API_KEY` est lue depuis l'environnement (`dotenv-rails`), jamais versionnée.

### Limites connues

- L'appel au LLM est **synchrone** dans le cycle requête/réponse (pas d'Active Job) : une requête
  lente bloque un worker Puma.
- Aucun quota ni limite de messages par conversation n'est appliqué (le code existe mais est
  commenté dans `Message`).
- Le modèle et ses paramètres ne sont pas configurables par foyer.

## Architecture

```
User ──< Member >── Household ──< FridgeItem
 │                      │
 └──────< Chat >────────┘──< Message
```

- Un **User** peut appartenir à un foyer via un **Member** ; il possède ses **Chats**.
- Un **Household** regroupe les membres, les aliments du frigo et les conversations.
- Un **Message** porte un rôle (`user` / `assistant`) et un contenu Markdown.

Flux d'une demande de recette :

```
Utilisateur ─▶ MessagesController#create
                 └─▶ ruby_llm : prompt système + historique + tools
                       ├─▶ FridgeInventoryTool ─▶ PostgreSQL
                       └─▶ HouseholdMembersTool ─▶ PostgreSQL
                 ◀─ réponse streamée ─▶ Turbo Stream ─▶ navigateur
```

## Installation

### Prérequis

- Ruby 3.3.5 (rbenv / asdf)
- PostgreSQL
- `libvips` (traitement d'images)
- Une clé API OpenAI

### Étapes

```bash
git clone git@github.com:MTAdrien/homenu.git
cd homenu
bin/setup
```

`bin/setup` installe les gems et prépare la base de données. Renseignez ensuite votre clé API (voir
ci-dessous) avant de démarrer.

## Configuration

Créez un fichier `.env` à la racine :

```bash
OPENAI_API_KEY=sk-votre-cle
```

| Variable | Environnement | Description |
|---|---|---|
| `OPENAI_API_KEY` | tous | Clé API OpenAI utilisée par `ruby_llm` |
| `DATABASE_URL` | production / CI | Connexion PostgreSQL |
| `REDIS_URL` | production | Action Cable (`config/cable.yml`) |
| `RAILS_MASTER_KEY` | production | Déchiffrement des credentials |

Le fichier `.env` est ignoré par Git : ne le committez jamais.

## Utilisation

```bash
bin/dev
```

L'application est disponible sur <http://localhost:3000>.

1. Créez un compte, puis un **foyer** et ses **membres**.
2. Remplissez le **frigo** (onglet *Fridge*).
3. Appuyez sur **Next Meal** pour une suggestion immédiate, ou ouvrez l'onglet **Assistant** pour
   discuter avec l'IA.

## Tests et qualité

```bash
bin/rails test              # tests unitaires et fonctionnels (Minitest)
bin/rails test:system       # tests système (Capybara + Selenium)
bin/rubocop                 # style (rubocop-rails-omakase)
bin/brakeman --no-pager     # analyse statique de sécurité
bin/bundler-audit           # vulnérabilités des gems
bin/importmap audit         # vulnérabilités des dépendances JS
```

Ces mêmes vérifications sont exécutées par GitHub Actions sur chaque pull request et sur `master`.

## Déploiement

L'application est déployée sur **Heroku** :

```bash
git push heroku master
heroku run rails db:migrate
```

Variables à définir sur l'app Heroku : `OPENAI_API_KEY`, `RAILS_MASTER_KEY`, `REDIS_URL`
(`DATABASE_URL` est fournie par l'add-on PostgreSQL).

Un `Dockerfile` de production et une configuration Kamal sont également présents dans le dépôt.

## Structure du projet

```
app/
├── controllers/      # logique applicative (dont l'orchestration LLM)
├── models/           # Household, Member, FridgeItem, Chat, Message, User
├── tools/            # outils RubyLLM exposés au modèle
├── views/            # ERB + partials Turbo Stream
├── helpers/          # rendu Markdown assaini
└── assets/stylesheets/
    ├── components/
    └── pages/
config/
├── initializers/ruby_llm.rb   # configuration du client LLM
└── routes.rb
db/                   # migrations et schéma
test/                 # Minitest + fixtures
```

## Contribuer

1. Créez une branche depuis `master` (`feature/…`, `fix/…`, `qol/…`).
2. Vérifiez `bin/rubocop` et `bin/rails test` avant de pousser.
3. Ouvrez une pull request : la CI doit être verte avant merge.

---

<p align="center">Fait avec 🍳 par l'équipe HomeNu.</p>
