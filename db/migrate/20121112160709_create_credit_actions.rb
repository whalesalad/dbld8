class CreateCreditActions < ActiveRecord::Migration
  def change
    create_table :credit_actions do |t|
      t.string    :slug
      t.integer   :cost

      t.timestamps
    end

    add_index :credit_actions, :slug, :unique => true

    # Create some initial credit actions.
    credit_actions = {
      'registration' => 1000,
      'activity_create' => -10
    }.each do |slug, cost|
      CreditAction.create(:slug => slug, :cost => cost)
    end

  end
end
