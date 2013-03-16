json.(purchase, :id)
json.description purchase.to_s
json.(purchase, :status, :identifier, :coins, :created_at)