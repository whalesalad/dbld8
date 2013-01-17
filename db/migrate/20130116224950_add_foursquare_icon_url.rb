class AddFoursquareIconUrl < ActiveRecord::Migration
  def up
    add_column :locations, :foursquare_icon, :string
  end

  def down
    remove_column :locations, :foursquare_icon, :string
  end
end
