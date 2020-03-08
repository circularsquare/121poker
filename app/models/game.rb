class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :cards, dependent: :destroy

  def init
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    suits = ['S', 'H', 'C', 'D']
    ranks.collect do |rank|
      suits.collect do |suit|
        self.cards << Card.new({:game_id => self.id, :rank => rank, :suit => suit, :location => -1})
        self.save
      end
    end
  end

  # to implement: modify location of card to player
  # currently: removes cards from deck
  def deal_cards
    deck = self.cards
    13.times do
      4.times do |i|
        random_card = deck[rand(deck.length)]
        deck.delete(random_card)
      end
    end
  end

  # locations are deck, table, or players
  def move_card(card, destination)
    card.location = destination
    card.save
  end

  def change_position
    @card = Card.find(1)
    @card.location = 'deck[placeholder]'
  end

  # creates player under the current game and the specified user
  def add_user_player(user)
    @player = Player.new({:ai => '', :game_id => self.id, :user_id => user.id, :money => 0, :username => user.username, :location => 1})
    self.players << @player
    self.save
  end

  # creates ai player under the current game and the user who made it
  def add_ai_player(type, user)
    @player = Player.new({:ai => type, :game_id => self.id, :user_id => user.id, :money => 0, :username => 'ai 1', :location => 1})
    self.players << @player
    self.save
  end

end
