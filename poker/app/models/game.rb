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
    Player.create({:ai => nil, :game => self, :username => user.username, :user => user, :location => 'new player'})
  end
  def add_ai_player()
    Player.create({:ai => 'ai 1', :game => self, :username => 'ai', :user => user, :location => 'new ai player'})
  end

end
