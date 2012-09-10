class JoinUsersAndInterests < ActiveRecord::Migration
  def change
    create_table :interests_users, :id => false do |t|
      t.integer :user_id
      t.integer :interest_id
    end

    add_index :interests_users, [:user_id, :interest_id]
    add_index :interests_users, [:interest_id, :user_id]
  end
end
