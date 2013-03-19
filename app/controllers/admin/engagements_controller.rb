class Admin::EngagementsController < AdminController
  respond_to :json, :only => [:unlock]
  
  before_filter :get_engagement, :except => [:index]

  def index
    @title = 'Engagements'
    @engagements = Engagement.page(params[:page]).per(50)
  end

  def show
    @activity = @engagement.activity
  end

  def unlock
    @engagement = Engagement.find(params[:id])
    @unlock_user = User.find_by_id(params[:user_id])

    if @unlock_user.nil?
      render json: { error: 'The user could not be found.' }
    end

    unlocker = UnlockEngagementService.new(@engagement, @unlock_user)

    unless unlocker.unlockable?
      return json_error "The current user cannot unlock this engagement."
    end

    # If the engagement was already unlocked
    if @engagement.unlocked?
      return json_error "This engagement has already been unlocked"
    end

    # Finally, let's unlock this beast.
    if unlocker.unlock!
      render json: { unlocked: true } and return
    else
      return json_error "An error ocurred unlocking this engagement."
    end
  end

  def destroy
    @engagement.destroy
    redirect_to admin_activity_path(@engagement.activity), :flash => { :success => "Successfully deleted engagement #{@engagement.to_s}." }
  end

  private

  def get_engagement
    @engagement = Engagement.find(params[:id])
  end
end
