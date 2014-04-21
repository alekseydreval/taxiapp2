class AddDispatcherIdToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :dispatcher_id, :integer
  end
end
