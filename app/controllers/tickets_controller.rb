class TicketsController < ApplicationController
  load_resource except: :create

  def new
  end

  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      redirect to: root_path, notice: 'Succeess'
    else
      redirect to: root_path, notice: 'Failure'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end


  private
    def ticket_params
      params.require(:ticket).permit(:name, :phone, :pick_up_latlon, :drop_off_latlon, :pick_up_time)
    end


end