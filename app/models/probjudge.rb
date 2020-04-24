class Probjudge

  def initialize(pcards, tcards) #takes in the person's cards and table's cards
      @pcards = pcards
      @tcards = tcards
      judge()
  end

  def judge()
    strToRank = {'2'=>0, '3'=>1, '4'=>2, '5'=>3, '6'=>4, '7'=>5, '8'=>6, '9'=>7, '10'=>8, 'J'=>9, 'Q'=>10, 'K'=>11, 'A'=>12}
    strToSuit = {'S'=>0, 'H'=>1, 'C'=>2, 'D'=>3}
    @player = Array.new(2)
    @table = Array.new(@tcards.length())
    for i in 0...2
      @player[i] = {'rank' => strToRank[@pcards[i].rank], 'suit' => strToSuit[@pcards[i].suit]}
    end
    for i in 0...@tcards.length()
      @table[i] = {'rank' => strToRank[@tcards[i].rank], 'suit' => strToSuit[@tcards[i].suit]}
    end
    @cards = @player + @table

    @ranks = Array.new(13,0)
    @suits = Array.new(4,0) # suit order spade, heart, club, diamond
    for i in 0...@cards.length()
        # increment appropriate array counts for each card
        @ranks[@cards[i]['rank']] += 1
        @suits[@cards[i]['suit']] += 1
    end

    case @cards.length()
    when 2
      return twoCards()
    when 5
      return fiveCards()
    when 6
      return sixCards()
    else
      return sevenCards()
    end
  end

  def twoCards()
    score = 0.0
    possible = 0.0
    if @player[0]['rank'] == @player[1]['rank']  # pair
      score += 3
    end
    possible += 3
    if @player[0]['suit'] == @player[1]['suit']  # possible flush
      score += 2
    end
    possible += 2
    if (@player[0]['rank'] - @player[1]['rank']).abs() == 1  # possible straight
      score += 1
    end
    possible += 1
    if @player[0]['rank'] > 8 or @player[1]['rank'] > 8  # high card of face card
      score += 2
    end
    possible += 2
    return score/possible
  end

  def fiveCards()
    score = 0.0
    possible = 0.0
    # flushes, or 'same suit' hands
    if @suits.max == 4  # 4/5 of a flush
      score += 3
    elsif @suits.max == 5  # 5/5 of a flush
      score += 9
    end
    # 'same rank' hands
    possible += 9
    sorted = @ranks.sort
    if sorted[12] == 4  # four of a kind
      score += 15
    elsif sorted[12] == 3 and sorted[11] == 2 # full house (2 & 3 of a kind)
      score += 12
    elsif sorted[12] == 3  # three of a kind
      score += 8
    elsif sorted[11] == sorted[12] and sorted[12] == 2  # two pair
      score += 6
    elsif @ranks.max == 2 and (@ranks.index(@ranks.max) == @cards[0]['rank'] or @ranks.index(@ranks.max) == @cards[1]['rank'])  # pair, and one of the cards is the players
      if @ranks.index(@ranks.max) > 7
        score += 4
      else
        score += 2
      end
    end
    possible += 15
    return score/possible
  end

  def sixCards()
    score = 0.0
    possible = 0.0
    # flushes, or 'same suit' hands
    if @suits.max == 4  # 4/5 of a flush
      score += 1.5
    elsif @suits.max == 5  # 5/5 of a flush
      score += 9
    end
    # 'same rank' hands
    possible += 9
    sorted = @ranks.sort
    if sorted[12] == 4  # four of a kind
      score += 15
    elsif sorted[12] == 3 and sorted[11] == 2 # full house (2 & 3 of a kind)
      score += 12
    elsif sorted[12] == 3  # three of a kind
      score += 8
    elsif sorted[11] == sorted[12] and sorted[12] == 2  # two pair
      score += 6
    elsif @ranks.max == 2 and (@ranks.index(@ranks.max) == @cards[0]['rank'] or @ranks.index(@ranks.max) == @cards[1]['rank']) and @ranks.index(@ranks.max) > 9  # pair, and one of the cards is the players
      score += 3
    end
    possible += 15
    return score/possible
  end

  def sevenCards()
    handjudge = Handjudge.new(@pcards + @tcards)
    return (handjudge.judge()*0.75) / (10**11)
  end

end
