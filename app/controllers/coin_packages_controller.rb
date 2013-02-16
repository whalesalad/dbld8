class CoinPackagesController < ApplicationController
  skip_filter :require_token_auth
  respond_to :json

  def index
    @coin_packages = CoinPackage.all
  end

end
