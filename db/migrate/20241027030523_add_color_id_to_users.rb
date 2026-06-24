class AddColorIdToUsers < ActiveRecord::Migration[6.1]
  def change
     add_column :users, :color_id, :integer
  end
end
