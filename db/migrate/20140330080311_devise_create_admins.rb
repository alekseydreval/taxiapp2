class DeviseCreateAdmins < ActiveRecord::Migration
  def change
    create_table(:admins) do |t|
      t.integer :user_id
    end
  end
end
