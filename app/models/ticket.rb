class Ticket < ActiveRecord::Base
  has_many :suggestions
  has_many :drivers, through: :suggestions
  belongs_to :dispatcher, class_name: 'User'
  belongs_to :driver, class_name: 'User'

  accepts_nested_attributes_for :suggestions

  validates_presence_of :name, :phone, :pick_up_time, :pick_up_latlon, :drop_off_latlon,
                                                      :pick_up_location, :drop_off_location
  validates_format_of :phone, with: /\+?\d+/
  validates_associated :dispatcher

  scope :scheduled, -> { where("driver_id IS NOT NULL") }
  scope :unscheduled, -> { where("driver_id IS NULL") }

  def pick_up_time=(time)
  	super DateTime.strptime(time, "%Y/%m/%d %H:%M")
  end

  def take(driver_id)
    update_attribute driver_id: driver_id
  end

  def formatted_time
    self.pick_up_time.strftime("%e %b, %H:%M")
  end

end
