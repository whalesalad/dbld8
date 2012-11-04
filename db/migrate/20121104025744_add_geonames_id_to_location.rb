class AddGeonamesIdToLocation < ActiveRecord::Migration
  def up
    add_column :locations, :geoname_id, :integer
    add_index :locations, :geoname_id, :unique => :true
  end

  def down
    remove_column :locations, :geoname_id
  end
end
