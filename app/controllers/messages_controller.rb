class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = "You are HomeNu, a family cooking assistant.

    You help the household create recipes and meal plans.

    You have access to a tool that reads the current household fridge.
    When the user asks what is in the fridge or what they can cook,
    use the fridge inventory tool before answering.

    Never invent ingredients that are supposedly in the fridge."

  def create
    #@chat = household.chats.find(params[:chat_id])
    @chat = current_household.chats.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      # ruby_llm_chat = RubyLLM.chat
      # response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      ruby_llm_chat = RubyLLM.chat
        ruby_llm_chat.with_tool(
          FridgeInventoryTool.new(household: current_household)
        )

        response = ruby_llm_chat
          .with_instructions(instructions)
          .ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      @chat.generate_title_from_first_message
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def ask_llm
    @ruby_llm_chat = RubyLLM.chat

    build_conversation_history

    # @ruby_llm_chat.with_tool()
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

  # def household_context
  #   "Here are the members of the household: #{@household.members}.\n\n Here are the available items in the fridge #{@fridge_items.all}."
    def household_context
      members = current_household.members.pluck(:first_name)

      "The household members are: #{members.join(', ')}."
    end

  def instructions
    [SYSTEM_PROMPT, household_context].compact.join("\n\n")
  end
end
