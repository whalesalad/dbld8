class CoinPackagesController < ApiController

  def index
    @coin_packages = CoinPackage.all
  end

end
