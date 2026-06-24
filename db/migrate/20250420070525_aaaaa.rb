class Aaaaa < ActiveRecord::Migration[6.1]
  def change
     add_column :places, :group_id, :integer
  end
end
