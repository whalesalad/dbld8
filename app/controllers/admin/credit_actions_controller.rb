class Admin::CreditActionsController < AdminController
  before_filter :get_credit_action, :only => [:show, :edit, :update]

  def index
    @credit_actions = CreditAction.order('created_at ASC')
  end

  def new
    @credit_action = CreditAction.new    
  end

  def create
    @credit_action = CreditAction.new(params[:credit_action])
    
    if @credit_action.save
      redirect_to admin_credit_actions_path, success: 'Credit action created successfully.'
    else
      render action: "new"
    end
  end

  def edit

  end

  def destroy
    @activity.destroy
    redirect_to admin_activities_path, :flash => { :success => "Successfully deleted activity #{@activity.to_s}." }
  end

  private

  def get_credit_action
    @credit_action = CreditAction.find_by_slug(params[:id])
  end
end
