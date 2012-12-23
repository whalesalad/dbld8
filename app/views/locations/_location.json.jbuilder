json.id location.id

json.(location, :type, :name)

if location.venue?
  json.location_name location.location_name
  json.venue location.venue
  json.address location.address
end

json.state location.state if location.american?
json.country location.short_country

json.distance location.distance if location.distance.present?