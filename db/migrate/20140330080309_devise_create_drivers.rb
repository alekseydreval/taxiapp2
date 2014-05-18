class DeviseCreateDrivers < ActiveRecord::Migration
  def change
    create_table(:drivers) do |t|
      t.integer :user_id
      t.string :phone
      t.string :name
      t.string :surname
      t.string :state
    end
  end
end
