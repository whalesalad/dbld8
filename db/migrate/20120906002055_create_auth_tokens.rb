class CreateAuthTokens < ActiveRecord::Migration
  def change
    create_table :auth_tokens do |t|
      t.integer :user_id, :unique => true
      t.string :token, :unique => true

      t.timestamps
    end
  end
end
