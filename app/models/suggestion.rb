class Suggestion < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :driver, class_name: 'User', foreign_key: 'user_id'

  validates_associated :driver
  
  state_machine :state, initial: :suggested do
    after_transition on: :accept, do: :take_ticket

    event :accept do
      transition suggested: :accepted
    end

    event :reject do
      transition suggested: :rejected
    end
  end

  def take_ticket
    ticket.take self.driver_id
  end


end
