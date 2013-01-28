json.(activity, :id, :title, :details, :created_at, :updated_at, :day_pref, :time_pref)

json.relationship activity.relationship(@authenticated_user)
json.unread_count activity.engagements.unread_for(@authenticated_user).count

json.cache! activity do |json|
  json.engagements_count activity.engagements.not_ignored.count

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