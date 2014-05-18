class CarTrackerController < WebsocketRails::BaseController

  def initialize_session
    controller_store[:positions] = []   
  end

  # Needs to be tested against multiple connections
  def update_location
    begin
      if message[:latlng].present?
        puts "Location for #{message[:driver_id]} -> #{message[:latlng]}"
        connection_store[:position] = message
        connection_store[:position][:driver_info] ||= Driver.find(message[:driver_id])
        insert_or_update_position(controller_store[:positions], connection_store[:position])
        locationChanged
      end  
    rescue Exception => e
      puts e
    end
  end

  def get_drivers_location
    puts controller_store
    trigger_success controller_store
  end

  private
  
  def insert_or_update_position collection, position
    if collection.empty?
      controller_store[:positions].push position
    else
      collection.each_with_index do |pos, ind|
        puts pos["driver_id"], position["driver_id"]
        if pos["driver_id"] == position["driver_id"]
          collection[ind] = position
        else
          collection.push position
        end
      end
    end
  end

  def locationChanged
    response = prepare_response
    CarTrackerHelper.set_positions response
    WebsocketRails["drivers_locations"].trigger('update', response)
    puts "NOTIFIED --> #{response}"
  end

  def prepare_response
    { positions: connection_store.collect_all(:position).reject(&:blank?) }
  end

end
