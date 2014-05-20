class User < ActiveRecord::Base
  
  # For dispatcher
  has_many :suggestions
  has_many :tickets, through: :suggestions

  VALID_ROLES = %w(dispatcher driver admin)

  validates :username,
  :uniqueness => {
    :case_sensitive => false
  }

  validates :role, :inclusion => { :in => VALID_ROLES }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  attr_accessor :login

  state_machine :state, initial: "в работе" do

    event "сделать перерыв" do
      transition "в работе" => "на перерыве"
    end

    event "продолжить работу" do
      transition "на перерыве" => "в работе"
    end

    event "выйти из системы" do
      transition ["в работе", "на перерыве"] => "не в сети"
    end

    event "начать работу" do
      transition "не в сети" => "в работе"
    end

  end

  def self.drivers
    where("role = 'driver'")
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def notify_break
    WebsocketRails["dispatcher"].trigger 'break', { text: "Водитель #{self.fullname} взял перерыв" }
  end

  def notify_continue
    WebsocketRails["dispatcher"].trigger 'continue', { text: "Водитель #{self.fullname} закончил перерыв" }
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

  def fullname
    "#{self.name} #{self.surname}"
  end

  def current_ticket
    self.tickets.with_state(:started).first
  end

  def self.available_for_suggestions(ticket)
    where("users.role = 'driver' AND state = 'normal' ") - ticket.suggestions.without_state(:rejected).map(&:driver)
  end

end
