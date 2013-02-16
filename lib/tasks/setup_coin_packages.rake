namespace :dbld8 do
  task :setup_coin_packages => :environment do
    puts "Setting up initial coin packages..."

    packages = [
      { coins: 100 },
      { coins: 250 },
      { coins: 500, popular: true },
      { coins: 900 },
      { coins: 2000 },
      { coins: 5000 },
      { coins: 20000 },
    ]

    packages.each do |package|
      package[:identifier] = "#{package[:coins]}_coins"
      CoinPackage.create(package)
    end
  end
end