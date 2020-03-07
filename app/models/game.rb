class Game < ApplicationRecord
  has_many :players
  has_many :cards

  # to implement: modify location of card to player
  # currently: removes cards from deck
  def deal_cards
    deck = Card.all
    13.times do
      4.times do |i|
        random_card = deck[rand(deck.length)]
        deck.delete(random_card)
      end
    end
  end

  def change_position
    @card = Card.find(1)
    @card.location = 'deck[placeholder]'
  end

  # creates player under the current game and the specified user
  def add_user_player(user)
    @player = Player.new({:ai => '', :game_id => self.id, :user_id => user.id, :money => 0, :username => user.username, :location => 'new player'})
    self.players << @player
    self.save
  end

  # creates ai player under the current game and the user who made it
  def add_ai_player()
    Player.create({:ai => 'ai 1', :game => self, :username => 'ai', :user => user, :location => 'new ai player'})
  end

end
