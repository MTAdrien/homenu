class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household
  before_action :set_member, only: [:edit, :update, :destroy]

  def new
    @member = @household.members.new
  end

  def create
    @member = @household.members.new(member_params)
    @member.user = current_user

    respond_to do |format|
      if @member.save
        format.turbo_stream
        format.html { redirect_to new_household_member_path(@household) }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "member-form",
            partial: "members/form",
            locals: { household: @household, member: @member }
          ), status: :unprocessable_entity
        }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @member.update(member_params)
      redirect_to settings_path, notice: "Membre mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.destroy
    redirect_to settings_path, notice: "Membre retiré.", status: :see_other
  end

  private

  def set_household
    @household = Household.find(params[:household_id])
  end

  def set_member
    @member = @household.members.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:first_name, :role)
  end
end
