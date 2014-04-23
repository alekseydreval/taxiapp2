class CarTrackerController < WebsocketRails::BaseController
  # Needs to be tested against multiple connections
  def update_location
    if message[:latlng].present?
      puts "Location for #{message[:driver_id]} -> #{message[:latlng]}"
      connection_store[:position] = message
      connection_store[:position][:driver_info] ||= User.find(message[:driver_id])

      controller_store[:positions] ||= [] 
      controller_store[:positions].push connection_store[:position]
      locationChanged
    end
  end

  def get_drivers_location
    trigger_success controller_store
  end

  private

  def locationChanged
    response = prepare_response
    CarTrackerHelper.set_positions response
    WebsocketRails["drivers_locations"].trigger('update', response)
    puts "NOTIFIED"
  end

  def prepare_response
    { positions: connection_store.collect_all(:position).reject(&:blank?) }
  end

end
