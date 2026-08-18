class HouseholdsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household, only: [:show, :update]

  def new
    @household = Household.new
  end

  def create
    @household = Household.new(household_params)
    @household.user = current_user
    @household.users << current_user
    if @household.save
      redirect_to new_household_member_path(@household), notice: "Foyer créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @household.update(household_params)
      redirect_to @household, notice: "Foyer mis à jour."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_household
    @household = Household.find(params[:id])
  end

  def household_params
    params.require(:household).permit(:name)
  end
end
