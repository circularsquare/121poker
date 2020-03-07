json.extract! player, :id, :ai, :username, :game, :location, :created_at, :updated_at
json.url player_url(player, format: :json)
