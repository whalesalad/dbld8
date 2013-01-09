class AddKarmaToUserAction < ActiveRecord::Migration
  def up
    add_column :user_actions, :karma_value, :integer, :default => 0
    rename_column :user_actions, :cost, :coin_value
  end

  def down
    rename_column :user_actions, :coin_value, :cost
    remove_column :user_actions, :karma_value
  end
end
