class Ticket < ActiveRecord::Base
  has_many :suggestions
  has_many :drivers, through: :suggestions
  has_many :expenses
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
    after_transition on: :canel, do: :notify_canceled_ticket

    event :start do
      transition taken: :started
    end

    event :finish do
      transition started: :finished
    end

    event :cancel do
      transition [:taken, :started] => :unassigned
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
      suggestions.where("user_id = ? AND state = 'rejected' ", driver.id).each &:destroy
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
    WebsocketRails["dispatcher_#{self.dispatcher_id}"].trigger 'finish', { ticket: self, text: "Водитель #{self.driver.username} завершил поездку" }
  end

  def notify_canceled_ticket
    WebsocketRails["dispatcher_#{self.dispatcher_id}"].trigger 'cancel', { ticket: self, text: "Водитель #{self.driver.username} отменил поездку" }
  end

  def formatted_time
    self.pick_up_time.strftime("%e %b, %H:%M")
  end

  def formatted_route
    [pick_up_latlon.split(' ').reverse.map(&:to_f), drop_off_latlon.split(' ').reverse.map(&:to_f)]
  end

  def rejected_by
    @rejected_by ||= self.suggestions.with_state(:rejected).map{|s| s.driver.username }.uniq
  end

  def suggested_to
    @suggested_to ||= self.suggestions.without_state(:rejected).map{|s| s.driver.username }.uniq
  end

  def status_for_dispatcher(dispatcher)
    status = ""
  end

  def status_for_driver(driver)
    status = ""

    if self.started?
      status << "Выполняется"
    elsif self.taken?
      status << "Принята"
    elsif self.finished?
      return "Завершено"
    elsif self.suggestions.select{|sg| sg.driver == driver }.all?{ |sg| sg.rejected? }
      return "Отклонено"
    else
      return
    end

    if self.driver == driver
      status << " Вами"
    elsif self.driver
      status << " другим водителем"
    end

    status

  end

end
