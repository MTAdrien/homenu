class SettingsController < ApplicationController
  def show
    @household = current_user.households.first
  end
end
