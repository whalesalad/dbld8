json.(friendship, :id, :created_at, :approved)

json.user do
  json.partial! 'users/user', user: friendship.user
end

json.friend do
  json.partial! 'users/user', user: friendship.friend
end