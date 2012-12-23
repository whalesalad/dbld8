json.array!(@friendships) do |friendship|
  json.partial! friendship
end