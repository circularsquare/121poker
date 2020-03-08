class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :cards, dependent: :destroy

  def get_random_card
    return self.cards.where(:location => -1)[rand(self.cards.where(:location => -1).length)]
  end

  def init
    round = -1
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    suits = ['S', 'H', 'C', 'D']
    ranks.collect do |rank|
      suits.collect do |suit|
        self.cards << Card.new({:game_id => self.id, :rank => rank, :suit => suit, :location => -1})
        self.save
      end
    end
  end

  def deal(round)
    round_int = round.to_i
    case round_int
    when -1
      p 'you tried to deal to a game that hasnt started'
    when 0
      self.players.each do |player|
        p 'one player!!!'
        move_card(get_random_card, player.location)
        move_card(get_random_card, player.location)
      end
    when 1
      move_card(get_random_card, 0)  #moves cards to table
      move_card(get_random_card, 0)
      move_card(get_random_card, 0)
    when 2
      move_card(get_random_card, 0)
    when 3
      move_card(get_random_card, 0)
    else
      p '###deal case > 3, error###'
      p round
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

  def set_round(round)
    self.round = round
    self.save
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
