# run rake db:seed to run this file

# refreshes db (except users!)
Game.delete_all
Player.delete_all
Card.delete_all


ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
suits = ['S', 'H', 'C', 'D']

# spawns the 52 cards for the game on database start
ranks.collect do |rank|
  suits.collect do |suit|
    card = Card.create({:rank => rank, :suit => suit, :location => 'deck'})
  end
end
