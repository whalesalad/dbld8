class CreateCoinPackages < ActiveRecord::Migration
  def change
    create_table :coin_packages do |t|
      t.string :identifier, :unique => true
      t.integer :coins
      t.boolean :popular, :default => false

      t.timestamps
    end

    add_index :coin_packages, :identifier, :unique => true
  end
end
