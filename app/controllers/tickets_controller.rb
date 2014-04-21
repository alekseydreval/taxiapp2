class TicketsController < InheritedResources::Base
  load_resource except: :create, collection: [:open_queue, :scheduled]

  def open_queue
    @tickets = current_user.tickets.unscheduled
  end

  def scheduled
    @tickets = current_user.tickets.scheduled
  end

  private
    def permitted_params
      params.permit(ticket: [:name, :phone, :pick_up_latlon, :drop_off_latlon, 
                             :pick_up_time, :pick_up_location, :drop_off_location, :note])
    end

end
