class AddFeaturesToUser < ActiveRecord::Migration
  def up
    add_column :users, :features, :hstore
    add_hstore_index :users, :features, :type => :gin

    say_with_time "Setting default user features..." do
      User.reset_column_information
      User.all.each do |user|
        user.features['max_activities'] = '3'
        user.save!
      end
    end
  end

  def down
    remove_column :users, :features
  end

end
