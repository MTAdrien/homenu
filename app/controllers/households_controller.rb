class HouseholdsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household, only: [ :edit, :update ]

  def new
    @household = Household.new
  end

  def edit
  end

  def create
    @household = Household.new(household_params)
    @household.owner = current_user

    if @household.save
      # Member.create!(user: current_user, household: @household)
      redirect_to new_household_member_path(@household), notice: "Household created."
    else
      Rails.logger.debug @household.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @household = current_household
    redirect_to new_household_path and return unless @household
  end

  def update
    if @household.update(household_params)
      redirect_to @household, notice: "Household updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_household
    @household = current_household
  end

  def household_params
    params.require(:household).permit(:name)
  end
end
