class User < ActiveRecord::Base

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

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end


end
