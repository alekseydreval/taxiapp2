class RenameSuggestionsUserIdToDriverId < ActiveRecord::Migration
  def change
    rename_column :suggestions, :user_id, :driver_id
  end
end
