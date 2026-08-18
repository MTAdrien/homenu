class FridgeItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fridge_item, only: [:edit, :update, :destroy]

  def new
    @fridge_item = FridgeItem.new
  end

  def create
    @fridge_item = FridgeItem.new(fridge_item_params)
    if @fridge_item.save
      redirect_to fridge_items_path, notice: "Article ajouté."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @fridge_item.update(fridge_item_params)
      redirect_to fridge_items_path, notice: "Article mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fridge_item.destroy
    redirect_to fridge_items_path, notice: "Article supprimé.", status: :see_other
  end

  private

  def set_fridge_item
    @fridge_item = FridgeItem.find(params[:id])
  end

  def fridge_item_params
    params.require(:fridge_item).permit(:name, :quantity, :expiration_date)
  end
end
