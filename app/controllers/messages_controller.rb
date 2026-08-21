class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = "You are HomeNu, a family cooking assistant.

    You help the household create recipes and meal plans.

    You have access to a tool that reads the current household fridge.
    When the user asks what is in the fridge or what they can cook,
    use the fridge inventory tool before answering.
    You also have access to a tool that returns the number of members in the household.
    Use it when the number of people is relevant, especially when suggesting recipe quantities or meal portions.

    Never invent ingredients that are supposedly in the fridge.

    When suggesting a recipe, always respond in Markdown.

Use exactly this structure:

## Recipe title

**Preparation time:** X minutes
**Cooking time:** X minutes
**Servings:** X people

### Ingredients

- ingredient with quantity
- ingredient with quantity
- ingredient with quantity

### Preparation

1. First step
2. Second step
3. Third step

Adapt ingredient quantities to the number of household members.
Keep the recipe clear and concise.
Do not wrap the response in a Markdown code block."


  def create
    @chat = current_household.chats.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      @assistant_message = @chat.messages.create!(role: "assistant", content: "")

      response = ask_llm

      @assistant_message.update!(content: response.content)
      broadcast_replace(@assistant_message)
      @chat.generate_title_from_recipe(@assistant_message.content)
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def ask_llm
    @ruby_llm_chat = RubyLLM.chat

    build_conversation_history

    @ruby_llm_chat.with_tool(FridgeInventoryTool.new(household: current_household))
    @ruby_llm_chat.with_tool(HouseholdMembersTool.new(household: current_household))
    @ruby_llm_chat.with_instructions(instructions)

    @ruby_llm_chat.ask(@message.content) do |chunk|
      next if chunk.content.blank?

      @assistant_message.content += chunk.content
      broadcast_replace(@assistant_message)
    end
  end

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(@chat, target: helpers.dom_id(message), partial: "messages/message", locals: { message: message })
  end

  def build_conversation_history
    @chat.messages.each do |message|
      next if message.content.blank?

      @ruby_llm_chat.add_message(message)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end


    def household_context
      members = current_household.members.pluck(:first_name)

      "The household members are: #{members.join(', ')}."
    end

  def instructions
    # [SYSTEM_PROMPT, household_context].compact.join("\n\n")
    SYSTEM_PROMPT
  end
end
