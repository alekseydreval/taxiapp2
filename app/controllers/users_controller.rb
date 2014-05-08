class UsersController < ApplicationController

  before_action :authenticate_user!

  def take_a_brake
    current_user.take_a_brake
    redirect_to :back, notice: "Вы уведомили диспетчеров о своем переыве.<br/> Новые предложения больше не будут поступать"
  end

  def continue
    current_user.continue
    redirect_to :back, notice: 'Вы завершили переыв'
  end

  def drivers
    @users = User.drivers
    @title = "Водители"
    render "index"
  end
end