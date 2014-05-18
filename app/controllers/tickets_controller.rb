class TicketsController < InheritedResources::Base
  load_resource except: :create, collection: [:open_queue, :scheduled]
  
  # for Driver
  def scheduled
    @title = "Запланированные"
    @tickets = current_user.tickets.scheduled
    render "index"
  end
  
  # for Driver
  def suggested
    @title = "Предложенные"
    @tickets = current_user.suggestions.without_state(:rejected).map(&:ticket).compact.select(&:suggested?)
    render "index"
  end

  def take
    if @ticket.take_by(current_user)
      redirect_to :root, notice: "Вы присвоили поездку"
    else
      redirect_to :back, error: @ticket.errors.messages
    end
  end

  def index
    @tickets = current_user.tickets
  end

  def start
    @ticket.start
    redirect_to :root, notice: "Вы начали поездку"
  end

  def finish
    @ticket.update permitted_params["ticket"]
    @ticket.finish
    redirect_to :root, notice: "Вы завершили поездку"
  end

  def reject
    @ticket.reject_by(current_user)
    redirect_to :back
  end

  private
    def permitted_params
      params.permit(ticket: [:name, :phone, :pick_up_latlon, :drop_off_latlon, 
                             :pick_up_time, :pick_up_location, :drop_off_location, :note, :driver_ids,
                             :payment_amount, :payment_tip, :payment_method,
                             :dispatcher_id])
    end

end
