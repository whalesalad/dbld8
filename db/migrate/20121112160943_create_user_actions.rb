class CreateUserActions < ActiveRecord::Migration
  def change
    create_table :user_actions do |t|
      t.integer   :user_id
      t.string    :type
      t.string    :action_slug
      t.integer   :cost
      t.integer   :related_id
      t.string    :related_type

      t.timestamps
    end
  end
end
