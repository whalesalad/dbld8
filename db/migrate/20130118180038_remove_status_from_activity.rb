class RemoveStatusFromActivity < ActiveRecord::Migration
  def up
    remove_column :activities, :status
  end

  def down
    add_column :activities, :status, :string
  end
end
