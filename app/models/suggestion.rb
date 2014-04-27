class Suggestion < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :driver, class_name: 'User', foreign_key: 'user_id'

  validates_associated :driver

  after_create :notify_driver
  
  state_machine :state, initial: :suggested do
    event :reject do
      transition suggested: :rejected
    end
  end

  def notify_driver
    WebsocketRails["driver_#{self.driver.id}"].trigger 'new', {suggestion: self, ticket: self.ticket}
  end


end
