class RenameBodyBackToMessage < ActiveRecord::Migration
  def up
    rename_column :messages, :body, :message
  end

  def down
    rename_column :messages, :message, :body
  end
end
