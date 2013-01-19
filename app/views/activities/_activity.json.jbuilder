json.(activity, :id, :title, :details, :created_at, :day_pref, :time_pref)

json.relationship activity.relationship(@authenticated_user)

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