json.cache! location do |json|
  json.id location.id

  json.(location, :type, :name, :latitude, :longitude)

  if location.venue?
    json.location_name location.location_name
    json.venue location.venue
    json.address location.address
    json.icon_retina location.icon(64, true)
    json.icon location.icon(32, true)
  end

  json.state location.state if location.american?
  json.country location.short_country
end

json.distance location.distance if location.distance.present?