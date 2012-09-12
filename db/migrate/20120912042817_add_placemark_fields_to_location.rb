class AddPlacemarkFieldsToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :locality, :string
    add_column :locations, :administrative_area, :string
    add_column :locations, :country, :string
  end
end
