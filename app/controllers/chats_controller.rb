class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats
    @household = current_household
  end

  def show
    @chat    = current_user.chats.find(params[:id])
    @messages = @chat.messages
    @message = Message.new
    @household = @chat.household
  end

  def create
    unless current_household
      redirect_to new_household_path, alert: "Create a household first"
      return
    end

    @chat = current_user.chats.build(
      name: Chat::DEFAULT_TITLE,
      household: current_household
    )
  if @chat.save
      if params[:auto_recipe]
    @auto_message = @chat.messages.create!(
      role: "user",
      content: "Propose-moi un repas avec ce qu'il y a dans mon frigo pour toutes les personnes du foyer."
    )

    ai_chat = RubyLLM.chat

    ai_chat.with_tool(
      FridgeInventoryTool.new(household: current_household)
    )

    ai_chat.with_tool(
      HouseholdMembersTool.new(household: current_household)
    )

    ai_chat.with_instructions(MessagesController::SYSTEM_PROMPT)

    response = ai_chat.ask(@auto_message.content)

    @chat.messages.create!(
      role: "assistant",
      content: response.content
    )

    @chat.generate_title_from_recipe(response.content)
      end

      redirect_to chat_path(@chat)
  else
      @chats = current_user.chats.reload
      render :index, status: :unprocessable_entity
  end
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    redirect_to chats_path
  end
end
