json.id activity.id
json.(activity, :title, :details, :created_at)
json.(activity, :status, :relationship)

unless activity.engaged?
  json.engagements_count activity.engagements.not_ignored.count
end

json.user do
  json.partial! activity.user
end

json.wing do
  json.partial! activity.wing
end

json.location do
  json.partial! activity.location
end