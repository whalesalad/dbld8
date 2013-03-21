class RemoveNameFromLocation < ActiveRecord::Migration
  def up
    remove_column :locations, :name
  end

  def down
    add_column :locations, :name, :string
  end
end
