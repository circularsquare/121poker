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
    self.big_blind = 2
    self.small_blind = 1
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
      end_game()
    else
      p '###deal case > 3, error###'
      p round
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
    if get_player(self.current_player).ai != ''
      action_loop()
    end
    self.save
  end

  # helper function that puts blinds in pot upon dealing cards in first round of game
  # sets first player to person after big blind
  def addBlinds()
    s_blind_loc = get_next_player(self.dealer) # location of small blind player
    b_blind_loc = get_next_player(s_blind_loc) # location of big blind player
    self.current_player = get_next_player(b_blind_loc)
    s_blind_player = get_player(s_blind_loc)  # actual players to change money
    b_blind_player = get_player(b_blind_loc)
    # put money from small and big blind players into pot
    s_blind_player.money -= self.small_blind
    b_blind_player.money -= self.big_blind
    self.high_bet = big_blind
    self.high_better = b_blind_loc
    self.pot += big_blind + small_blind
    b_blind_player.save
    s_blind_player.save
    self.save
  end

  # Automates taking actions for each AI, advances round and deals under correct conditions
  def action_loop()
    go_once_around = true
    player = get_player(self.current_player)

    while ((not self.high_better == self.current_player) or go_once_around) and get_player(self.current_player).ai != ""
      go_once_around = false
      action_info = ai_action(player)
      action(action_info[0], action_info[1], player.id)
      player = get_player(self.current_player)
    end

    if self.high_better == self.current_player
      set_round(self.round + 1 % 5)
      deal(self.round)
    end

    if self.players.where(:in_hand => true).length == 1
      end_game()
    end
    self.save
  end

  # handles player actions
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
        self.high_better = @player.location
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
        self.high_better = @player.location
      end
    when 'check'
    when 'call'
      if high_bet > @player.money + @player.in_pot_current
        amount = @player.money
      else
        amount = high_bet - @player.in_pot_current
      end
      self.pot += amount
      @player.money -= amount
    else
      p 'invalid action'
    end
    @player.in_pot_current += amount
    @player.in_pot_hand += amount
    self.current_player = get_next_player(self.current_player)
    self.save
    @player.save

    if self.players.where(:in_hand => true).length == 1
      p 'bruhhhhhhhhhhhhhhhhhhhhhhhhh'
      p self.players.where(:in_hand => true)[0].username
      end_game()
    end

  end

  # helper function to run when a user needs to take a turn
  def player_action(type, amount, player)
    action(type, amount, player)
    action_loop()
  end

  # Defines a basic AI, giving them actions to take under different conditions
  def ai_action(player)
    type = player.ai
    if self.high_bet == 0
      return 'check', 0
    elsif self.high_bet < player.money/2
      return 'call', self.high_bet
    else
      return 'fold', 0
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
    players = self.players.where(:in_game == true)
    players.each do |player|
      cards = self.cards.where(:location => player.location) + self.cards.where(:location => 0)
      if cards.length() == 7
        handjudge = Handjudge.new(cards)
        player.score = handjudge.judge()
        p 'scoreeeeeeeeeeeeeeee'
        p player.score
        p 'scorrererer'
        player.hand = scoreToString[(player.score.to_f/(100**5)).round()]
        p player.hand
        player.save
        if player.score > high_score
          high_score = player.score
          winners = [player]
        elsif player.score == high_score
          winners.append(player)
        end
      else
        p 'invalid number of cards passed'
        return players
      end
    end
    return winners
  end

  def end_game()
    get_winners()
  end

  # At the end of a round, this is called to reset card deck, correctly allocate the round's money,
  # and increment the dealer
  def reset_game()

    while (self.pot > 0)
      #gets people with highest score
      winners = get_winners()
      winners.each do |winner|
        #TO IMPLEMENT: more advanced side pots
        winner.money += self.pot / winners.length()
        winner.save
      end
      self.pot = 0
      print(winners)
    end

    # reset deck of cards
    self.cards.where.not(:location => -1).each do |card|
      card.location = -1
      card.save
    end
    # reset amount each player has in the pot to 0
    self.players.each do |player|
      player.in_pot_hand = 0
      player.in_pot_current = 0
      player.save
    end
    # reset pot to empty, increment dealer

    self.dealer = (self.dealer + 1)%10 + 10
    while self.players.where(:location => self.dealer).length == 0
      self.dealer = (self.dealer + 1)%10 + 10
    end
    set_round(0)
    deal(0)
    self.save
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

  # returns next player that is in the game
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
