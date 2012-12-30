class SplitUserTable < ActiveRecord::Migration
  def up
    add_column :users, :type, :string

    say_with_time "Converting users to their subsequent objects..." do
      User.reset_column_information
      
      User.all.each do |user|
        if user.facebook_id.present?
          user.type = 'FacebookUser'
        else
          user.type = 'EmailUser'
        end
        user.save!
      end
    end
  end

  def down
    remove_column :users, :type
  end
end
