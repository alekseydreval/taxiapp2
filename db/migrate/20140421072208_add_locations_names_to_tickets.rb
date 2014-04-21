class AddLocationsNamesToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :pick_up_location, :string
    add_column :tickets, :drop_off_location, :string
  end
end
