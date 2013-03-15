class PurchasesController < ApplicationController
  respond_to :json

  before_filter :get_purchase, :only => [:show]

  def index
    @purchases = base_query
    respond_with @purchases
  end

  def show
    respond_with @purchase
  end

  def create
    @purchase = @authenticated_user.purchases.new(params[:purchase])

    if @purchase.save
      respond_with(@purchase, 
        :status => :created, 
        :location => @purchase,
        :template => 'purchases/show')
    else
      respond_with(@purchase, :status => :unprocessable_entity)
    end
  end

  private

  def base_query
    @authenticated_user.purchases
  end

  def get_purchase
    begin
      @purchase = base_query.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return json_not_found "The requested purchase was not found."
    end
  end

end