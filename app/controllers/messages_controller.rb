class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = "You are a XXXXX.\n\n"

  def create
    @chat = current_user.chats.find(params[:chat_id])
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
    "Here are the members of the household: #{@household.members}."
  end

  def instructions
    [SYSTEM_PROMPT, challenge_context].compact.join("\n\n")
  end
end
