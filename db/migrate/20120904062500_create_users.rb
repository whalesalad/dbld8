class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :email
      t.string    :password
      t.integer   :facebook_id, :limit => 8
      t.string    :first_name
      t.string    :last_name
      t.date      :birthday
      t.boolean   :single
      t.string    :interested_in
      t.string    :gender
      t.text      :bio

      t.timestamps
    end

    add_index :users, :email, :unique => true
  end
end
