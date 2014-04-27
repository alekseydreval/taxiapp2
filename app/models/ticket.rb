class Ticket < ActiveRecord::Base
  has_many :suggestions
  has_many :drivers, through: :suggestions
  belongs_to :dispatcher, class_name: 'User'
  belongs_to :driver, class_name: 'User'

  accepts_nested_attributes_for :suggestions

  validates_presence_of :name, :phone, :pick_up_time, :pick_up_latlon, :drop_off_latlon,
                                                      :pick_up_location, :drop_off_location, :dispatcher_id
  validates_numericality_of :payment_tip, :payment_amount, allow_nil: true
  validates_format_of :phone, with: /\+?\d+/

  scope :scheduled, -> { where("driver_id IS NOT NULL and tickets.state = 'taken'") }
  scope :unscheduled, -> { where("driver_id IS NULL") }

  state_machine :state, initial: :unassigned do
    after_transition on: :start, do: :update_start_time
    after_transition on: :finish, do: :update_finish_time

    event :start do
      transition taken: :started
    end

    event :finish do
      transition started: :finished
    end
  end


  def self.for_driver(driver)
    where("driver_id = ?", driver.id).order('pick_up_time ASC')
  end

  def pick_up_time=(time)
  	super DateTime.strptime(time, "%Y/%m/%d %H:%M")
  end

  def take_by(driver)
    if self.driver
      self.errors.messages["driver"] = "Поездка уже присвоена"
      false
    else
      update driver_id: driver.id, state: "taken"
      WebsocketRails["dispatcher_#{self.dispatcher_id}"].trigger 'update', { ticket: self, answer: 'accepted', text: 'Предложение принято' }
    end
  end

  def reject_by(user)
    self.suggestions.without_state(:rejected).where("user_id = ?", user.id).first.reject
    WebsocketRails["dispatcher_#{self.dispatcher_id}"].trigger 'update', { ticket: self, answer: 'rejected', text: 'Предложение было отклонено' }
  end

  def update_start_time
    update started_at: DateTime.now
  end

  def update_finish_time
    update finished_at: DateTime.now
  end


  def formatted_time
    self.pick_up_time.strftime("%e %b, %H:%M")
  end

  def formatted_route
    [pick_up_latlon.split(' ').reverse, drop_off_latlon.split(' ').reverse]
  end

end
