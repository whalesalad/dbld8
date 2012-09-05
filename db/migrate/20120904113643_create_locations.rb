class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string    :name, :null => false
      t.decimal   :lat, :precision => 15, :scale => 10
      t.decimal   :lng, :precision => 15, :scale => 10
      t.integer   :facebook_id, :limit => 8

      t.timestamps
    end

    add_index :locations, :facebook_id, :unique => true
  end
end
