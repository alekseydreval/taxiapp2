class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    if current_user.role == 'dispatcher'
      redirect_to new_ticket_path
    elsif current_user.role == 'driver'
      if ticket = current_user.current_ticket
        redirect_to ticket
      else
        render "driver"
      end
    end
  end

end
