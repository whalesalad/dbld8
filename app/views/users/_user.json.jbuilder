json.(user, :id, :full_name, :first_name, :age, :gender, :total_karma)

if user.location.present?
  json.location user.location.to_s
end

json.photo user.photo