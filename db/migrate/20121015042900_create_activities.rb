class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string  :title, :null => false
      t.string  :details
      
      t.string  :day_pref
      t.string  :time_pref

      t.integer :location_id
      t.integer :user_id, :null => false
      t.integer :wing_id

      t.string  :status

      t.timestamps
    end

    add_index :activities, :user_id
    add_index :activities, :wing_id
    add_index :activities, :status

  end
end
