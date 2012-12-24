json.(user, :id)
json.full_name user.to_s
json.first_name user.first_name
json.age user.age

if user.location.present?
  json.location user.location.to_s
end

json.photo user.photo