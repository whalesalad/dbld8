class CreateEngagements < ActiveRecord::Migration
  def change
    create_table :engagements do |t|
      t.string    :status
      
      t.integer   :user_id, :null => false
      t.integer   :wing_id, :null => false

      t.integer   :activity_id, :null => false

      t.text      :message

      t.timestamps
    end

    add_index :engagements, :user_id
    add_index :engagements, :wing_id
    add_index :engagements, :status

    # There can only be one engagement per pair of user/wing to an activity
    add_index :engagements, [:user_id, :activity_id], :unique => true
    add_index :engagements, [:wing_id, :activity_id], :unique => true

  end
end
