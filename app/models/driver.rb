class Driver < ActiveRecord::Base

  belongs_to :user, dependent: :destroy

  has_many :tickets, class_name: "Ticket"
  has_many :suggestions


  state_machine :state, initial: :normal do
    after_transition on: :take_a_brake, do: :notify_break
    after_transition on: :continue, do: :notify_continue

    event :take_a_brake do
      transition normal: :paused
    end

    event :continue do
      transition paused: :normal
    end
  end

  def notify_break
    WebsocketRails["dispatcher"].trigger 'break', { text: "Водитель #{self.fullname} взял перерыв" }
  end

  def notify_continue
    WebsocketRails["dispatcher"].trigger 'continue', { text: "Водитель #{self.fullname} закончил перерыв" }
  end

  def current_ticket
    self.tickets.with_state(:started).first
  end

  def self.available_for_suggestions(ticket)
    with_state(:normal) - ticket.suggestions.without_state(:rejected).map(&:driver)
  end

  def fullname
    "#{self.name} #{self.surname}"
  end

end
