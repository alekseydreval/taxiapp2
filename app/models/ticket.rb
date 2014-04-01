class Ticket < ActiveRecord::Base
  has_many :suggestions
  has_many :drivers, through: :suggestions, class_name: 'User'
  
  def pick_up_time=(time)
  	super DateTime.strptime(time, "%Y/%m/%d %H:%M")
  end

end
