
#je ne mets volontairement pas param :household. Le LLM ne doit pas pouvoir choisir lui-même le foyer à consulter. C’est notre application qui lui donnera le bon household, comme dans le cours où le user est injecté dans le constructeur plutôt que choisi par le LLM
#

class FridgeInventoryTool < RubyLLM::Tool
  description "Returns the items currently available in the household fridge."

  def initialize(household:)
    @household = household
  end

  def execute
    # le code qui va chercher les aliments du frigo.
    items = @household.fridge_items

    return "The fridge is empty." if items.empty?

    items.map do |item|
       {
        name: item.name,
        quantity: item.quantity,
        expiry_date: item.expiry_date
      }

    end
  end
end
