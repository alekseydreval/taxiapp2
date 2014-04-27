class UsersController < ApplicationController

  before_action :authenticate_user!

  def take_a_brake
    current_user.take_a_brake
    redirect_to :back
  end

  def continue
    current_user.continue
    redirect_to :back
  end
end