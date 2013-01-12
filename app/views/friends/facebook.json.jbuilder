json.array!(@users) do |user|
  if user.is_a? User
    json.partial! 'users/user', user: user
  else
    json.partial! 'friends/facebook_user', user: user
  end
end