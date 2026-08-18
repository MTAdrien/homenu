class MembersController < ApplicationController
  before_action :authenticate_user!

  def new
    @household = Household.find(params[:household_id]) if params[:household_id]
    @member = Member.new
  end
end
