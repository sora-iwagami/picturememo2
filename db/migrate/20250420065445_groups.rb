class Groups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.boolean :is_share
    end
  end
end
