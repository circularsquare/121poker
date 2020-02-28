json.extract! card, :id, :suit, :rank, :location, :game_id, :created_at, :updated_at
json.url card_url(card, format: :json)
