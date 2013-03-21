json.partial! @activity

# Add extra mini engagement data here for the slide-up
# view on the Activity so you know you messaged them
if @activity.relationship == Activity::IS_ENGAGED
  json.engagement do
    json.id @activity.engagement.id
    json.created_at_ago time_ago_in_words(@activity.engagement.created_at)
    json.display_name you_or_wing_name_for_engagement(@activity.engagement)
  end
end