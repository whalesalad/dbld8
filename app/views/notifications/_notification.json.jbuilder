json.(notification, :id, :uuid, :created_at)

json.notification notification.to_s

json.callback notification.callback_str
