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

end
