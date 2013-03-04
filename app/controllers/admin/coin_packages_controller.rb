class Admin::CoinPackagesController < AdminController
  before_filter :get_package, :only => [:edit, :update, :destroy]

  def index
    @title = 'Coin Packages'
    @packages = CoinPackage.all
  end

  def new
    @package = CoinPackage.new
  end

  def create
    @package = CoinPackage.new(params[:coin_package])
    
    if @package.save
      redirect_to admin_coin_packages_path, success: 'Package created successfully.'
    else
      respond_with @package
    end
  end

  def edit

  end

  def update
    @package.update_attributes(params[:coin_package])

    if @package.save
      redirect_to admin_coin_packages_path, success: 'Package modified successfully.'
    else
      respond_with @package
    end
  end

  def destroy
    @activity.destroy
    
    redirect_to admin_activities_path, 
      :flash => { :success => "Successfully deleted activity #{@activity.to_s}." }
  end

  private

  def get_package
    @package = CoinPackage.find(params[:id])
    # if @package.nil?

    # end
  end
end
