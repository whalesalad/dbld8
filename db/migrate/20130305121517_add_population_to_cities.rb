class AddPopulationToCities < ActiveRecord::Migration
  def change
    add_column :locations, :population, :integer, :limit => 8, :null => true
  end
end
