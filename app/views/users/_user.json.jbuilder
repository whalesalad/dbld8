json.(user, :id)
json.full_name user.to_s
json.first_name user.first_name
json.age determine_age(user.birthday)

if user.location.present?
  json.location user.location.to_s
end

json.photo user.photo