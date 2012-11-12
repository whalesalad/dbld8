class CreateCreditActions < ActiveRecord::Migration
  def change
    create_table :credit_actions do |t|
      t.string    :slug
      t.integer   :cost

      t.timestamps
    end

    add_index :credit_actions, :slug, :unique => true
  end
end
