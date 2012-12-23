json.(friendship, :id, :created_at, :approved)

json.user do
  json.partial! friendship.user
end

json.friend do
  json.partial! friendship.friend
end