json.(user, :id, :full_name, :first_name, :age, :gender, :total_karma)

if user.facebook_id.present?
  json.facebook_id user.facebook_id
end

if user.location.present?
  json.location user.location.to_s
end

# friends/wings
unless user.approved.nil?
  json.approved user.approved
end

json.photo user.photo