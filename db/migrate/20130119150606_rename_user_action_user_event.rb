class RenameUserActionUserEvent < ActiveRecord::Migration
  def up
    rename_table :user_actions, :events
  end

  def down
    rename_table :events, :user_actions
  end
end
