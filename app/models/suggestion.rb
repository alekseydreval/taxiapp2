class Suggestion < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :driver, class_name: 'User', foreign_key: 'user_id'
end
