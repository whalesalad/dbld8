class AddPurchaseCountToPackages < ActiveRecord::Migration
  def change
    add_column :coin_packages, :purchases_count, :integer, :default => 0

    say_with_time "Adding purchase counts to packages..." do
      CoinPackage.reset_column_information
      CoinPackage.all.each do |package|
        CoinPackage.update_counters package.id, purchases_count: package.purchases.length
      end
    end
  end
end
