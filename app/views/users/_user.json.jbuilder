json.cache! user do |json|
  json.(user, :id, :full_name, :first_name, :age, :gender, :total_karma)

  if user.is_a? FacebookUser
    json.facebook_id user.facebook_id
  end

  if user.location.present?
    json.location user.location.to_s
  end

  json.photo user.photo
end

json.approved user.approved?