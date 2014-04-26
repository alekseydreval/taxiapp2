class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.integer :ticket_id
      t.integer :driver_id
      t.string :expenses_type
      t.integer :amount

      t.timestamps
    end
  end
end
