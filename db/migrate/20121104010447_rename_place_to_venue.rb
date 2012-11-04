class RenamePlaceToVenue < ActiveRecord::Migration
  def up
    rename_column :locations, :place, :venue
  end

  def down
    rename_column :locations, :venue, :place
  end
end
