class RenemeIatIngToLatLng < ActiveRecord::Migration[6.1]
  def change
    rename_column :places, :iat, :lat
    rename_column :places, :ing, :lng
  end
end
