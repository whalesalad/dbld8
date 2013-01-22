class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id, :null => false
      t.string :token, :null => false

      t.timestamps
    end

    add_index :devices, :user_id
    add_index :devices, :token, :unique => true
  end
end
