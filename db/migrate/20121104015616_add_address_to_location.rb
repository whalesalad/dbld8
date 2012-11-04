class AddAddressToLocation < ActiveRecord::Migration
  def up
    add_column :locations, :address, :string

    say_with_time "Adding addresses to 4SQ venues..." do
      Location.reset_column_information
      Location.venues.where(:address => nil).find_each do |location|
        puts "Requesting address for #{location} (ID #{location.id})..."
        
        location.address = location.foursquare_venue.address
        
        if location.address_changed?
          puts "  >> Address found! #{location.address}"
          location.save!
        end

        puts "  >> Sleeping half a second before continuing ..."
        sleep 0.5
        puts ""
      end
    end
  end

  def down
    remove_column :locations, :address
  end
end
