class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.household.chats
  end

  def show
    @chat    = current_user.household.chats.find(params[:id])
    @message = Message.new
  end

  def create
    @household = current_user.household
    @chat = @household.chats.build(title: "Untitled", user: current_user)

    if @chat.save
      redirect_to chat_path(@chat)
    else
      @chats = @household.chats
      render "households/show"
    end
  end
end
