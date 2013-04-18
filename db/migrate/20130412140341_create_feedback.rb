class CreateFeedback < ActiveRecord::Migration
  def change
    create_table :feedback do |t|
      t.integer :user_id
      t.text :message

      t.timestamps
    end

    add_index :feedback, :user_id
  end
end
