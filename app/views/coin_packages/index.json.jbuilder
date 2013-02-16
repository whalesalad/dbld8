json.array!(@coin_packages) do |coin_package|
  json.partial! coin_package
end