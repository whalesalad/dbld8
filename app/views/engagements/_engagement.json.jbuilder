json.(engagement, :id, :created_at)
json.created_at_ago time_ago_in_words(engagement.created_at)
json.updated_at engagement.updated_at
json.updated_at_ago time_ago_in_words(engagement.updated_at)

json.status engagement.status
json.display_name you_or_wing_name_for_engagement(engagement)

json.unread_count engagement.messages.unread_for(@authenticated_user).count

if engagement.was_unlocked?
  json.unlocked_at engagement.unlocked_at
  json.expires_at engagement.expires_at
  if engagement.expired?
    json.time_remaining 0
  else
    json.time_remaining distance_of_time_in_words_to_now(engagement.expires_at)
  end
  json.days_remaining engagement.days_remaining
end

if engagement.messages.first.present?
  json.primary_message engagement.messages.first.message
end

json.cache! [engagement, I18n.locale] do |json|
  json.user do
    json.partial! 'users/user', user: engagement.user
  end
  json.wing do
    json.partial! 'users/user', user: engagement.wing
  end
  json.activity do
    json.(engagement.activity, :id, :title)
    json.user do
      json.partial! 'users/user', user: engagement.activity.user
    end
    json.wing do
      json.partial! 'users/user', user: engagement.activity.wing
    end
  end
end