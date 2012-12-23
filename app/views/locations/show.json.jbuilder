json.id @location.id

json.(@location, :name, :type, :latitude, :longitude)

if @location.venue?
  json.location_name @location.location_name
  json.venue @location.venue
  json.address @location.address
end

json.locality @location.locality
json.state @location.state if @location.american?
json.country @location.short_country

json.distance @location.distance if @location.distance.present?

json.activities_count @location.activities.count
json.users_count @location.users.count