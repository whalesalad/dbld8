module EngagementHelper
  def you_or_wing_name_for_engagement(engagement)
    if @authenticated_user.id == engagement.user_id
      t(:you)
    else
      engagement.user.first_name
    end
  end
end