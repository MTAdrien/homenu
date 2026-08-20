class FridgeItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household
  before_action :set_fridge_item, only: [:show, :edit, :update, :destroy]

  def index
    @fridge_item = @household.fridge_items
  end

  def show
  end

  def new
    @fridge_item = @household.fridge_items.new
  end

  def create
    @fridge_item = @household.fridge_items.new(fridge_item_params)
    if @fridge_item.save
      redirect_to household_fridge_items_path, notice: "Added article"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
      if @fridge_item.update(fridge_item_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to household_fridge_items_path(@household), notice: "Updated article" }
        end

      else
        render :edit, status: :unprocessable_entity
      end
  end

  def destroy
    @fridge_item.destroy
    redirect_to household_fridge_items_path(@household), notice: "Deleted article", status: :see_other
  end

  private

  def set_household
    @household = Household.find(params[:household_id])
  end

  def set_fridge_item
    @fridge_item = @household.fridge_items.find(params[:id])
  end

  def fridge_item_params
    params.require(:fridge_item).permit(:name, :quantity, :expiry_date)
  end
end
