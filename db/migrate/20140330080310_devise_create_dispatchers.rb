class DeviseCreateDispatchers < ActiveRecord::Migration
  def change
    create_table(:dispatchers) do |t|
      t.integer :user_id
      t.string :name
      t.string :surname
    end
  end
end