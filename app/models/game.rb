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
        player.save
      end
      self.current_player = get_next_player(self.dealer)
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
    action_loop()
  end

  def action_loop()


    self.high_better = self.current_player
    go_once_around = true
    while (not self.high_better == self.current_player) or go_once_around
      go_once_around = false
      player = get_player(self.current_player)
      if player.ai != ""
        action_info = ai_action(player)
        action(action_info[0], action_info[1], player.id)
      end
      self.current_player = get_next_player(self.current_player)

      if self.players.where(:in_hand => true).length == 1
        return 0
      end
    end
    self.save
  end
  #handles player actions
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
        self.high_better = player
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
        self.high_better = player
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

  def ai_action(player)
    type = player.ai
    if self.high_bet < player.money
      return 'fold', 1
    else
      return 'fold', 1
    end

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
    if round == 4
      deal(4)
    end
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
  # creates ai player under the current game and the user who made it
  def add_ai_player(type, user)
    @player = Player.new({:ai => type, :game_id => self.id, :user_id => user.id, :money => 100, :username => 'ai 1', :location => self.get_empty_location(), :in_pot_hand => 0, :in_pot_current => 0})
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
  def get_player(location)
    return self.players.where(:location => location)[0]
  end
  def get_next_player(start)
    for i in 1..10
      to_check = (start + i)%10 + 10
      if self.players.where(:location => to_check).length == 1
        player = self.players.where(:location => to_check)[0]
        if player.in_hand
          return player.location
        end
      end
    end
    return -10
  end
end
