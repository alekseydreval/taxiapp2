class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.string :state
      t.integer :ticket_id
      t.integer :driver_id

      t.timestamps
    end
  end
end
