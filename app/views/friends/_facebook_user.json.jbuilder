json.(user, :facebook_id, :full_name, :gender)

if user.location.present?
  json.location user.location
end

json.photo user.photo