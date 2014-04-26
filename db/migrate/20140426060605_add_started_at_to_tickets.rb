class AddStartedAtToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :started_at, :datetime
  end
end
