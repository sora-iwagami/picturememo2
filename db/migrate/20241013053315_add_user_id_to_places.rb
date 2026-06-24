class AddUserIdToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :user_id, :integer
  end
end
