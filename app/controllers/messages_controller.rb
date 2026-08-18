class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      # Ici tu déclencheras la réponse de l'IA (recette, meal plan, liste de courses…)
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
