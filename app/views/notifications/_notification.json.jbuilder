json.(notification, :id, :uuid)

json.event notification.event.slug
json.notification notification.to_s

json.created_at notification.created_at
json.created_at_ago time_ago_in_words(notification.created_at)

json.push notification.push?

json.unread notification.unread?

json.callback notification.callback_str