json.cache! notification do |json|
  json.(notification, :id, :uuid)
  json.notification notification.to_s
  json.app_identifier notification.app_identifier
  json.push notification.push?
  json.unread notification.unread?
  json.created_at notification.created_at
end

json.photos notification.photos

json.created_at_ago time_ago_in_words(notification.created_at)