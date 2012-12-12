class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer   :user_id
      t.integer   :engagement_id
      t.text      :message

      t.timestamps
    end

    add_index :messages, :user_id
    add_index :messages, :engagement_id
  end
end
