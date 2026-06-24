class CreatePlaceTable < ActiveRecord::Migration[6.1]
  def change
    create_table :places do |t|
      t.string :place_name
      t.integer :category_id
      t.string :photo
      t.float :iat
      t.float :ing
      t.timestamps null: false
    end
  end
end
