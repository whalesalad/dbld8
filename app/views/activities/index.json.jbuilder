json.array!(@activities) do |activity|
  json.partial! activity
end