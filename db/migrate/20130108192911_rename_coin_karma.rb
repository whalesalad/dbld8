class RenameCoinKarma < ActiveRecord::Migration
  def up
    rename_column :user_actions, :coin_value, :coins
    rename_column :user_actions, :karma_value, :karma
  end

  def down
    rename_column :user_actions, :coins, :coin_value
    rename_column :user_actions, :karma, :karma_value
  end
end
