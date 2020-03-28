class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :cards, dependent: :destroy

  def get_random_card
    return self.cards.where(:location => -1)[rand(self.cards.where(:location => -1).length)]
  end

  def init
    self.round = -1
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    suits = ['S', 'H', 'C', 'D']
    self.pot = 0
    self.dealer = 10
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
        player.in_hand = true
      end
    when 1
      move_card(get_random_card, 0)  #moves cards to table
      move_card(get_random_card, 0)
      move_card(get_random_card, 0)
    when 2
      move_card(get_random_card, 0)
    when 3
      move_card(get_random_card, 0)
    when 4
      p 'Round 4'
      reset_game()
    else
      p '###deal case > 3, error###'
      p round
    end
    self.players.each do |player|
      player.in_pot_current = 0
    end
    self.high_bet = 0
    self.save

  end

  def action(type, amount, player)
    @player = Player.find(player.to_i)
    amount = amount.to_i
    case type
    when 'fold'
      @player.in_hand = false
    when 'bet'
      p 'in_pot_current', @player.in_pot_current
      p 'high_bet', self.high_bet
      if amount > @player.money
        amount = @player.money
      end
      if amount + @player.in_pot_current < self.high_bet
        p 'invalid bet'
      else
        @player.money -= amount
        self.pot += amount
        self.high_bet = amount + @player.in_pot_current
      end
    when 'raise'
      if amount > @player.money
        amount = @player.money
      end
      if amount + @player.in_pot_current < 2*self.high_bet
        p 'invalid raise'
      else
        @player.money -= amount
        self.pot += amount
        self.high_bet = amount + @player.in_pot_current
      end
    when 'check'
    when 'call'
      if high_bet > @player.money
        amount = @player.money
      else
        amount = high_bet
      end
      self.pot += amount
      @player.money -= amount
    else
      p 'invalid action'
    end
    @player.in_pot_current += amount
    @player.in_pot_hand += amount
    self.save
    @player.save
  end
  # locations are deck, table, or players
  def move_card(card, destination)
    card.location = destination
    card.save
  end

  def reset_game()
    # reset deck of cards
    self.cards.where.not(:location => -1).each do |card|
      card.location = -1
      card.save
    end
    # reset amount each player has in the pot to 0
    self.players.each do |player|
      player.in_pot_hand = 0
    end
    # reset pot to empty, increment dealer
    p 'Got here resetting game'
    self.pot = 0
    self.dealer = (self.dealer + 1)%10 + 10
    while self.players.where(:location => self.dealer).length == 0
      self.dealer = (self.dealer + 1)%10 + 10
    end
  end

  def change_position
    @card = Card.find(1)
    @card.location = 'deck[placeholder]'
  end

  def set_round(round)
    self.round = round
    self.save
  end

  # lets player leave game
  def leave_game(player)
    self.players.find(player.to_i).destroy
    self.save
  end

  # creates player under the current game and the specified user
  def add_user_player(user)
    @player = Player.new({:ai => '', :game_id => self.id, :user_id => user.id, :money => 100, :username => user.username, :location => self.get_empty_location(), :in_pot_hand => 0, :in_pot_current => 0})
    self.players << @player
    self.save
  end

  # gets next empty seat for a player to join game
  def get_empty_location()
    for i in 10..20
      if self.players.where(:location => i).length == 0
        return i
      end
    end
  end

  # creates ai player under the current game and the user who made it
  def add_ai_player(type, user)
    @player = Player.new({:ai => type, :game_id => self.id, :user_id => user.id, :money => 0, :username => 'ai 1', :location => self.players.length+10})
    self.players << @player
    self.save
  end

end
