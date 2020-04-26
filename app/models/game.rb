class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :cards, dependent: :destroy

  #gets a random card from the deck
  def get_random_card
    return self.cards.where(:location => -1)[rand(self.cards.where(:location => -1).length)]
  end

  def init
    self.round = 4
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    suits = ['S', 'H', 'C', 'D']
    self.pot = 0
    self.dealer = 10
    self.big_blind = 2
    self.small_blind = 1
    self.high_bet = -1
    self.high_better = -1
    ranks.collect do |rank|
      suits.collect do |suit|
        self.cards << Card.new({:game_id => self.id, :rank => rank, :suit => suit, :location => -1})
        self.save
      end
    end
  end

  # called at the start of each round to deal and reset round specific values
  def deal(round)
    round_int = round.to_i
    case round_int
    when 0
      self.players.each do |player|
        move_card(get_random_card, player.location)   # moves cards to users
        move_card(get_random_card, player.location)
        # player.in_hand = true
        player.save
      end
      addBlinds()
    when 1
      self.current_player = get_next_player(self.dealer)
      move_card(get_random_card, 0)  #moves cards to table
      move_card(get_random_card, 0)
      move_card(get_random_card, 0)
    when 2
      self.current_player = get_next_player(self.dealer)
      move_card(get_random_card, 0)
    when 3
      self.current_player = get_next_player(self.dealer)
      move_card(get_random_card, 0)
    when 4
      get_winners()
    else
      p 'deal case > 4 or < 0, error'
    end

    self.players.each do |player|
      player.in_pot_current = 0
      player.save
    end
    if round_int > 0 && round_int < 4
      self.high_bet = 0
      self.high_better = self.current_player
    end
    self.save
  end

  # helper function that puts blinds in pot upon dealing cards in first round of game
  # sets first player to person after big blind
  def addBlinds()
    s_blind_loc = get_next_player(self.dealer) # location of small blind player
    b_blind_loc = get_next_player(s_blind_loc) # location of big blind player
    # get player data for small and big blind locations
    s_blind_player = get_player(s_blind_loc)  # actual players to change money
    b_blind_player = get_player(b_blind_loc)
    # put money from small and big blind players into pot
    put_money(self.small_blind, s_blind_player)
    put_money(self.big_blind, b_blind_player)
    self.current_player = get_next_player(b_blind_loc)
    b_blind_player.save
    s_blind_player.save
    self.save
  end

  #puts money in pot and updates associated values
  def put_money(amount, player)
    if amount > player.money
      amount = player.money
    end
    if amount + player.in_pot_current > self.high_bet   # if player is new high bet (bets more than current highest)
      self.high_bet = amount + player.in_pot_current
      self.high_better = player.location
    end
    player.money -= amount    # puts money in correct places and takes from player's pot
    player.in_pot_current += amount
    player.in_pot_hand += amount
    self.pot += amount
    player.save
    self.save
  end

  # handles player actions
  # progresses current_player
  # progresses round if a round has completed
  def action(type, amount, player)
    @player = Player.find(player.to_i)
    amount = amount.to_i
    case type
    when 'fold'
      @player.in_hand = false
    when 'bet'
      if amount > @player.money
        amount = @player.money
      end
      if amount + @player.in_pot_current < self.high_bet
        p 'invalid bet'
      else
        put_money(amount, @player)
      end
    when 'raise'
      if amount > @player.money || (amount + @player.in_pot_current < 2*self.high_bet && 2*self.high_bet - @player.in_pot_current > @player.money)
        amount = @player.money
      elsif amount + @player.in_pot_current < 2*self.high_bet
        amount = 2*self.high_bet - @player.in_pot_current
      else
        amount = amount + self.high_bet - @player.in_pot_current
      end
      put_money(amount, @player)
    when 'check'
      # do nothing; high better already set to be player after dealer inside of deal()
    when 'call'
      amount = self.high_bet - @player.in_pot_current
      put_money(amount, @player)
    else
      p 'invalid action'
    end
    self.current_player = self.get_next_player(@player.location) # Set next player to current

    @player.save
    self.save
    if self.high_better == self.current_player #progress round if you've gone back around to the high better
      # unless no one raises and it's back to big blind, bb should be able to go
      if self.high_bet <= self.big_blind && self.round == 0 && self.high_better == get_next_player(get_next_player(self.dealer))
        self.high_better = get_next_player(get_next_player(get_next_player(self.dealer)))
      else
        set_round((self.round + 1))
        deal(self.round)
      end
    end
    if self.players.where(:in_hand => true).length <= 1
      set_round(4)
    end

    @player.save
    self.save
  end

  # Set of helper functions that check if player actions are valid
  def can_call?(player)
    return (self.high_bet > player.in_pot_current)
  end
  def can_check?(player)
    return (self.high_bet == player.in_pot_current)
  end
  def can_bet?(player)
    return (self.high_bet == 0) #todo: enforce min bet
  end
  def can_raise?(players) #todo: enforce min raise
    return (self.high_bet != 0)
  end

  # Gets called from deal(4)
  def end_game()
    get_winners()
  end

  def ai_turn?()
    return get_player(self.current_player).ai != ""
  end

  # takes actions for the AI that is up
  def ai_action()
    # sleep 3
    player = get_player(self.current_player)
    action_info = ai_one_logic(player)
    if player.ai == "2"
      action_info = ai_two_logic(player)
    end
    action(action_info[0], action_info[1], player.id) # this progresses current player and may progress round
    self.save
  end

  # Defines a basic AI, giving them actions to take under different conditions
  def ai_one_logic(player)
    type = player.ai
    if self.round == 0
      if self.high_bet < 5
        return 'call', 0
      else
        return 'fold', 0
      end
    else
      if self.high_bet == 0
        return 'bet', 2
      elsif self.high_bet < 4
        return 'raise', 4
      elsif self.high_bet >= 16
        return 'fold', 0
      else
        return 'call', 0
      end
    end
  end

  def ai_two_logic(player)
    type = player.ai
    probjudge = Probjudge.new(self.cards.where(:location => player.location), self.cards.where(:location => 0))
    prob = probjudge.judge()
    maxBet = (self.round * 5 * prob) + 5
    if self.round == 0
      if self.high_bet < 5
        return 'call', 0
      else
        return 'fold', 0
      end
    else
      if self.high_bet == 0
        return 'bet', maxBet / 2
      elsif self.high_bet < maxBet / 2
        return 'raise', (maxBet / 2) - self.high_bet
      elsif self.high_bet < maxBet
        return 'call', 0
      else
        return 'fold', 0
      end
    end
  end

  # locations are deck, table, or players
  def move_card(card, destination)
    card.location = destination
    card.save
  end

  def get_winners()
    scoreToString = {1=>'high card', 2=>'pair', 3=>'two pair', 4=>'three of a kind', 5=>'straight', 6=>'flush', 7=>'full house', 8=>'four of a kind', 9=>'straight flush', 10=>'royal flush'}
    high_score = -100^7
    winners = []
    players_in_hand = self.players.where(:in_hand => true)
    players_in_hand.each do |player|
      cards = self.cards.where(:location => player.location) + self.cards.where(:location => 0)
      if cards.length() == 7
        handjudge = Handjudge.new(cards)
        player.score = handjudge.judge()
        p 'score:'
        p player.score
        player.hand = scoreToString[(player.score.to_f/(100**5)).round()]
        player.save
        if player.score > high_score
          high_score = player.score
          winners = [player]
        elsif player.score == high_score
          winners.append(player)
        end
      else
        p 'invalid number of cards passed'
        return players_in_hand
      end
    end
    return winners
  end


  # At the end of a game, this is called to reset card deck (by button), correctly allocate the round's money,
  # and increment the dealer
  def reset_game()
    # If money in pot, distribute
    while (self.pot > 0)
      winners = []
      # In case where everyone has folded, set the winner to whoever is left
      if self.players.where(:in_hand => true).length <= 1
        winners = self.players.where(:in_hand => true)
      else
        #gets people with highest score
        winners = get_winners()
      end
      winners.each do |winner|
        #TO IMPLEMENT: more advanced side pots
        winner.money += self.pot / winners.length()
        winner.save
      end
      self.pot = 0
    end
    # reset deck of cards
    self.cards.where.not(:location => -1).each do |card|
      card.location = -1
      card.save
    end
    # reset amount each player has in the pot to 0
    self.players.each do |player|
      player.in_hand = true
      player.in_pot_hand = 0
      player.in_pot_current = 0
      player.hand = ''
      player.save
    end
    # reset pot to empty, increment dealer if not first hand
    if self.round != -1
      self.dealer = (self.dealer + 1)%10 + 10
    end
    # makes sure a player exists where the dealer is set
    while self.players.where(:location => self.dealer).length == 0
      self.dealer = (self.dealer + 1)%10 + 10
    end
    self.round = 0
    self.high_bet = 0
    self.high_better = get_next_player(self.dealer)
    self.save
    deal(self.round)
  end

  def set_round(round)
    p 'advanced game round to '
    p round
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
  # creates ai player under the current game and the user who made it
  def add_ai_player(type, user)
    @player = Player.new({:ai => type, :game_id => self.id, :user_id => user.id, :money => 100, :username => 'ai '+type.to_str, :location => self.get_empty_location(), :in_pot_hand => 0, :in_pot_current => 0})
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

  # returns next player that is in the game
  # takes in a location and returns the next location of a player in the game
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
