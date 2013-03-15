class Admin::PurchasesController < AdminController
  before_filter :get_purchase, :only => [:show, :destroy]

  def index
    @title = 'Purchases'
    @purchases = Purchase.order('created_at DESC').page(params[:page]).per(50)
  end

  def show
    # respond_with
  end

  def destroy
    @purchase.destroy
    redirect_to admin_purchases_path, :flash => { :success => "Successfully deleted purchase #{@purchase}." }
  end

  protected

  def get_purchase
    @purchase = Purchase.find(params[:id])
  end
end
