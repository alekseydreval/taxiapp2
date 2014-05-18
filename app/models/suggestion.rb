class Suggestion < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :driver

  validates_associated :driver

  after_create :notify_driver
  
  state_machine :state, initial: :suggested do
    event :reject do
      transition suggested: :rejected
    end
  end

  def notify_driver
    ticket.suggest      
    WebsocketRails["driver_#{self.driver.id}"].trigger 'new', {suggestion: self, ticket: self.ticket}
  end


end
