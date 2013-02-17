class AddFeaturesToUser < ActiveRecord::Migration
  def change
    add_column :users, :features, :hstore
    add_hstore_index :users, :features, :type => :gin
  end

  # say_with_time "Setting default user features..." do
  #   User.reset_column_information
  #   User.all.each do |user|

  #   end
  # end

end
