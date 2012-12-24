json.(user, :id, :full_name, :first_name, :age, :gender)

if user.location.present?
  json.location user.location.to_s
end

json.photo user.photo