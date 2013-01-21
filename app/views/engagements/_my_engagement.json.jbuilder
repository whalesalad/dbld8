json.(engagement, :id, :created_at)
json.created_at_ago time_ago_in_words(engagement.created_at)
json.status engagement.status