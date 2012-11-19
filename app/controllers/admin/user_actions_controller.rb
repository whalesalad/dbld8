class Admin::UserActionsController < AdminController

  def index
    @user_actions = UserAction.order('created_at DESC')
  end

end
