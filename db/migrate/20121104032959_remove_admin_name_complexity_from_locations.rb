class RemoveAdminNameComplexityFromLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :admin_name
    rename_column :locations, :admin_code, :state
  end

  def down
    add_column :locations, :admin_name, :string
    rename_column :locations, :state, :admin_code
  end
end
