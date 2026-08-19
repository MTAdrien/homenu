class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household

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

  private

  def set_household
    @household = Household.find(params[:household_id])
  end

  def member_params
    params.require(:member).permit(:first_name, :role)
  end
end
