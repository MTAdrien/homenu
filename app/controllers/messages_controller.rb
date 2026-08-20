class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = "You are a family assistant.\n\nYou are in charge of managing and creating recipes and meal plans for the family."

  def create
    @chat = household.chats.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      @chat.generate_title_from_first_message
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def household_context
    "Here are the members of the household: #{@household.members}.\n\n Here are the available items in the fridge #{@fridge_items.all}."
  end

  def instructions
    [SYSTEM_PROMPT, household_context].compact.join("\n\n")
  end
end
