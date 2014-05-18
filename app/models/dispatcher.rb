class Dispatcher < ActiveRecord::Base

  belongs_to :user, dependent: :destroy

  has_many :tickets
  has_many :suggestions, through: :tickets

end