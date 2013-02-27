class MeController < ApplicationController  
  respond_to :json
  
  before_filter :require_slug, :only => [:unlock, :check_unlock]
  before_filter :set_user
  
  def show
    respond_with @user,
      :template => 'users/show'
  end

  def update
    resp = if @user.update_attributes(params[:user])
      { :template => 'users/show' }
    else
      { :status => :unprocessable_entity }
    end

    respond_with(@user, resp)
  end

  def update_device_token
    @device = @user.devices.find_or_create_by_token(params[:device_token])
    respond_with @device
  end

  # check to see if an unlock is required for a particular section
  # in this case, max_activities is the only allowed.
  def check_unlock
    if params[:slug] != 'max_activities'
      return json_error "At this time, a user can only unlock for 'max_activities'."
    end

    unlocker = MaxActivityUnlockerService.new(@authenticated_user)

    render json: { 
      unlock: (unlocker.needs_unlock?) ? unlocker.next_unlock_event.json : false,
      activities_count: unlocker.activities_count,
      activities_allowed: unlocker.activities_allowed
    }
  end

  # perform an unlock. requires a slug
  # unlocked_five_activities -or- unlocked_ten_activities
  def perform_unlock
    allowed_unlocks = %w(unlocked_five_activities unlocked_ten_activities)

    unless allowed_unlocks.include?(params[:slug])
      return json_error "An invalid slug was specified. Only #{allowed_unlocks.join(', ')} are allowed."
    end

    unlocker = MaxActivityUnlockerService.new(@authenticated_user)

    unlock_event = unlocker.unlock!(params[:slug])
    
    if unlock_event
      render json: { 
        unlocked: true,
        activities_count: unlocker.activities_count,
        activities_allowed: unlocker.activities_allowed
      }
    else
      return json_error unlocker.errors.join(' ')
    end
  end

  private

  def set_user
    @user = @authenticated_user
  end

  def require_slug
    json_error "The 'slug' parameter is required." unless params[:slug].present?
  end

end
