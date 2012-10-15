class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string  :title
      t.string  :details
      t.integer :location_id
      t.integer :user_id
      t.integer :wing_id
      t.string  :status

      t.timestamps
    end
  end
end
