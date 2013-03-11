class AddUnlockedAtToEngagements < ActiveRecord::Migration
  def change
    add_column :engagements, :unlocked_at, :datetime

    say_with_time "Setting engagement unlocked_at based on events" do
      
      Engagement.reset_column_information
      
      Engagement.all.each do |engagement|
        engagement.events.each do |ev|
          if ev.is_a?(UnlockedEngagementEvent)
            engagement.unlocked_at = ev.created_at
            engagement.save!
          end
        end
      end

    end
  end
end
