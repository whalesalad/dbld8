class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string    :name, :null => false
      t.integer   :facebook_id, :limit => 8

      t.timestamps
    end
  end
end
