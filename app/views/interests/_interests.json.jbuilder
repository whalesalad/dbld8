json.interests interests do |interest|
  json.(interest, :id, :matched)
  json.name truncate(interest.name, length: 30)
end