json.(activity, :id, :title, :details, :created_at, :updated_at, :day_pref, :time_pref)

json.relationship activity.relationship(@authenticated_user)

json.engagements_count activity.engagements.not_ignored.count

json.unread_count activity.engagements.count(:joins => :message_proxies, :conditions => {'message_proxies.user_id' => @authenticated_user.id, 'message_proxies.unread' => true})

json.cache! activity do |json|
  json.user do
    json.partial! 'users/user', user: activity.user
  end

  json.wing do
    json.partial! 'users/user', user: activity.wing
  end

  json.location do
    json.partial! activity.location
  end
end