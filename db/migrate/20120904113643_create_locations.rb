class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string      :name, :null => false

      t.string      :locality
      t.string      :admin_name
      t.string      :admin_code
      t.string      :country

      t.float       :latitude
      t.float       :longitude

      t.integer     :facebook_id, :limit => 8

      t.timestamps
    end

    add_index :locations, :name, :unique => true
    add_index :locations, :facebook_id, :unique => true
  end
end
