entry.title(item.to_s)
entry.description item.location.full_name
entry.author do |author|
  author.name(item.participant_names)
end