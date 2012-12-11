class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.text :message
      t.integer :engagement_id

      t.timestamps
    end
  end
end
