class AddDriverIdToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :driver_id, :integer
  end
end
