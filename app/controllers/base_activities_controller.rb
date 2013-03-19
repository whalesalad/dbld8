class BaseActivitiesController < ApiController
  private

  def get_activity
    begin
      @activity = Activity.find(activity_id)
    rescue ActiveRecord::RecordNotFound
      return json_not_found "The requested activity was not found."
    end

    @activity.update_relationship_as(@authenticated_user)
  end

  def activity_owner_only
    return unauthorized! unless @activity.allowed?(@authenticated_user, :owner)
  end

  def activity_participants_only
    return unauthorized! unless @activity.allowed?(@authenticated_user, :all)
  end

end