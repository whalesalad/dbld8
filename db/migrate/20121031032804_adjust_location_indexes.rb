class AdjustLocationIndexes < ActiveRecord::Migration
  def change
    add_index :locations, :foursquare_id, :unique => true
    remove_index :locations, :name
    add_index :locations, :name, :unique => false
  end
end
