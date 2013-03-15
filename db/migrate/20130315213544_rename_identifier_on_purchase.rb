class RenameIdentifierOnPurchase < ActiveRecord::Migration
  def change
    rename_column :purchases, :coin_package_identifier, :identifier
  end
end
