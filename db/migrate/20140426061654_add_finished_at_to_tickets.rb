class AddFinishedAtToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :finished_at, :datetime
  end
end
