json.cache! ['short_notification', notification, notification.related] do |json|
  json.(notification, :id, :uuid)
  json.notification notification.to_s
  json.callback_url notification.callback_url
  json.push notification.push?
  json.unread notification.unread?
  json.created_at notification.created_at
end

if notification.has_dialog?
  json.dialog notification.dialog
end

json.photos notification.photos

json.created_at_ago time_ago_in_words(notification.created_at)