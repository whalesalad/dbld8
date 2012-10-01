class AddUuidToUser < ActiveRecord::Migration
  def change
    add_column :users, :uuid, :uuid
    add_index :users, :uuid, :unique => true
    
    say_with_time "Adding UUID's to users..." do
      require 'uuid'
      
      User.reset_column_information
      User.where(:uuid => nil).each do |user|
        _uuid = UUID.new
        user.update_column :uuid, _uuid.generate(:compact)
        puts "User #{user}: #{user.uuid}"
      end
    end
    
    # Handle the UUID noise, which actually is no longer necessary we do this in the code.
    execute 'ALTER TABLE users ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();';
    execute 'ALTER TABLE users ALTER COLUMN uuid SET NOT NULL;';
  end
end
