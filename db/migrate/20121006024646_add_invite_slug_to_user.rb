class AddInviteSlugToUser < ActiveRecord::Migration
  def change
    add_column :users, :invite_slug, :string
    add_index :users, :invite_slug, :unique => true
    
    say_with_time "Adding invite slugs to users..." do
      User.reset_column_information

      User.where(:invite_slug => nil).each do |user|
        user.update_column :invite_slug, user.generate_invite_slug
        puts "\tUser #{user}: #{user.invite_slug}"
      end
    end
  end
end
