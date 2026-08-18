Rails.application.routes.draw do
  get "messages/create"
  get "chats/show"
  get "fridge_items/new"
  get "fridge_items/create"
  get "fridge_items/edit"
  get "fridge_items/update"
  get "fridge_items/destroy"
  get "members/new"
  get "households/new"
  get "households/create"
  get "households/show"
  get "households/update"
  devise_for :users
  devise_scope :user do
  root to: "devise/registrations#new"
  end
  resources :households, only: [ :show, :new, :create, :update ] do
    resources :members, only: [ :new ]
  end
  resources :fridge_items, only: [ :new, :create, :edit, :update, :destroy ]

  resources :chats, only: [ :show, :new, :create ] do
    resources :messages, only: [ :create ]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  #
end
