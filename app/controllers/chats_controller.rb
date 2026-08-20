class ChatsController < ApplicationController
  before_action :authenticate_user!

  def create
    @household = Household.find(params[:household_id])
    @chat = Chat.new(title: "Untitled")
    @chat.household = @household
    @chat.user = current_user

    if @chat.save
      redirect_to chat_path(@chat)
    else
      @chats = @household.chats.where(user: current_user)
      render "household/show"
    end
  end
  def show
    @chat    = current_user.chats.find(params[:id])
    @message = Message.new
  end
end
