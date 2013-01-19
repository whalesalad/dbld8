class RenameMessageTextField < ActiveRecord::Migration
  def up
    rename_column :messages, :message, :body
  end

  def down
    rename_column :messages, :body, :message
  end
end
