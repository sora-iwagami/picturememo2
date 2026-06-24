class AddColorIdToDefaultUsers < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :color_id, from: nil, to: 1
  end
end
