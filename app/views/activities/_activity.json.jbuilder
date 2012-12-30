json.(activity, :id, :title, :details, :created_at, :day_pref, :time_pref, :status, :relationship)

if activity.engaged?
  json.accepted_engagement do
    json.id activity.accepted_engagement.id
    json.messages_count activity.accepted_engagement.messages.count
  end
else
  json.engagements_count activity.engagements.not_ignored.count
end

json.user do
  json.partial! 'users/user', user: activity.user
end

json.wing do
  json.partial! 'users/user', user: activity.wing
end

json.location do
  json.partial! activity.location
end