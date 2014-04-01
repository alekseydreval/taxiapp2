class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    render current_user.role
  end
end
