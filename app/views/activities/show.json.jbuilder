json.id @activity.id
json.(@activity, :title, :details, :created_at)
json.(@activity, :day_pref, :time_pref, :status, :relationship)

if @activity.engaged?
  json.accepted_engagement do
    json.partial! @activity.accepted_engagement
  end
else
  json.engagements_count @activity.engagements.not_ignored.count
end

json.user do
  json.partial! @activity.user
end

json.wing do
  json.partial! @activity.wing
end

json.location do
  json.partial! @activity.location
end