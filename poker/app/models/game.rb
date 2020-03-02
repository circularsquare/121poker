class Game < ApplicationRecord
  has_many :players
  has_many :cards

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
    @card.location = 'bruh'
  end

  def add_user_player(user)
    @player = Player.new({:ai => '', :game_id => self.id, :user_id => user.id, :money => 0, :username => user.username, :location => 'new player'})
    p self.players.size
    p @player
    p self
    self.players << @player
    self.save
  end
  def add_ai_player()
    Player.create({:ai => 'ai 1', :game => self, :username => 'ai', :user => user, :location => 'new ai player'})
  end

end
