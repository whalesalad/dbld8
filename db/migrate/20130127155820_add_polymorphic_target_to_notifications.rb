class AddPolymorphicTargetToNotifications < ActiveRecord::Migration
  def up
    change_table :notifications do |t|
      t.references :target, :polymorphic => { :default => 'Event' }
    end
    
    say_with_time "Migrating Notification.event into Notification.target poly field..." do
      Notification.reset_column_information
      Notification.all.each do |n|
        n.target = n.event
        n.save!
      end
    end

    remove_column :notifications, :event_id
  end

  def down
    change_table :notifications do |t|
      t.remove_references :target, :polymorphic => true
    end

    add_column :notifications, :event_id
  end
end
