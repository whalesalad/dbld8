json.array!(@locations) do |location|
  json.partial! location
end