class Ticket < ActiveRecord::Base
  has_many :suggestions
  has_many :drivers, through: :suggestions, class_name: 'User'

  validates_presence_of :name, :phone, :pick_up_time, :pick_up_latlon, :drop_off_latlon,
                                                      :pick_up_location, :drop_off_location
  validates_format_of :phone, with: /\+?\d+/
  
  def pick_up_time=(time)
  	super DateTime.strptime(time, "%Y/%m/%d %H:%M")
  end

end
