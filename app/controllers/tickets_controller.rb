class TicketsController < ApplicationController
  load_resource except: :create

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      redirect_to :root, notice: 'Succeess'
    else
      render :new
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
      params.require(:ticket).permit(:name, :phone, :pick_up_latlon, :drop_off_latlon, :pick_up_time, :pick_up_location, :drop_off_location)
    end


end