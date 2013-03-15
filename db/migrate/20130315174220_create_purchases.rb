class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.integer :user_id, :null => false
      t.string :coin_package_identifier, :null => false
      t.text :receipt, :null => false
      t.boolean :verified, :default => nil

      t.timestamps
    end

    add_index :purchases, :user_id
    add_index :purchases, :coin_package_identifier
    add_index :purchases, :verified
  end
end
