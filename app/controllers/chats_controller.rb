class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats
  end

  def show
    @chat    = current_user.chats.find(params[:id])
    @messages = @chat.messages
    @message = Message.new
  end

  def create
    # @chats = current_user.chats
    unless current_household
      redirect_to new_household_path, alert: "Create a household first"
      return
    end

    @chat = current_user.chats.build(name: Chat::DEFAULT_TITLE, household: current_household)

    if @chat.save
      redirect_to chat_path(@chat)
    else
      @chats = current_user.chats.reload
      render :index, status: :unprocessable_entity
    end
  end
end
