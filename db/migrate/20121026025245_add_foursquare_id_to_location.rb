class AddFoursquareIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :foursquare_id, :string
    add_column :locations, :place, :string
  end
end
