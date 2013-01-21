json.array!(@notifications) do |notification|
  json.partial! notification
end