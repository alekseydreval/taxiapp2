class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :state
      t.string :name
      t.string :phone
      t.text :pick_up_latlon
      t.text :drop_off_latlon
      t.datetime :pick_up_time
      t.datetime :drop_off_time

      t.timestamps
    end
  end
end
