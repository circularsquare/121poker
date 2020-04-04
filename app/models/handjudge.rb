class Handjudge

    def initialize(cards)
        @cards = cards
        judge()
    end

    def score_to_number(score)
      return score[0]*100**5 + score[1]*100**4 + score[2]*100**3 + score[3]*100**2 + score[4]*100 + score[5]
    end

    def judge()
        strToRank = {'2'=>0, '3'=>1, '4'=>2, '5'=>3, '6'=>4, '7'=>5, '8'=>6, '9'=>7, '10'=>8, 'J'=>9, 'Q'=>10, 'K'=>11, 'A'=>12}
        strToSuit = {'S'=>0, 'H'=>1, 'C'=>2, 'D'=>3}
        @ranks = Array.new(13,0)
        @suits = Array.new(4,0) # suit order spade, heart, club, diamond
        for i in 0...7
            card = @cards[i]
            # put string information for cards into format for array
            map_rank = strToRank[card.rank]
            map_suit = strToSuit[card.suit]
            # increment appropriate array counts for each card
            @ranks[map_rank] += 1
            @suits[map_suit] += 1
        end

        # first entry corresponds to general case (royal_flush being 10 to high_card being 1)
        # other entries are tiebreakers

        p 'hand cas'
        if royal_flush?
          p '1'
          return score_to_number(royal_flush?)
        elsif straight_flush?
          p '2'
          return score_to_number(straight_flush?)
        elsif four_of_a_kind?
          p '2'
          return score_to_number(four_of_a_kind?)
        elsif full_house?
          p '2'
          return score_to_number(full_house?)
        elsif flush?
          p '2'
          return score_to_number(flush?)
        elsif straight?
          p '2'
          p straight?
          return score_to_number(straight?)
        elsif three_of_a_kind?
          p '2'
          return score_to_number(three_of_a_kind?)
        elsif two_pair?
          p '3'
          p two_pair?
          return score_to_number(two_pair?)
        elsif pair?
          p '4'
          p pair?
          return score_to_number(pair?)
        elsif highest_card?
          p highest_card?
          p '5'
          return score_to_number(highest_card?)
        else
          p '6'
          return score_to_number([-1, -1, -1, -1, -1, -1])
        end
    end

    def royal_flush?
      return false
    end

    def straight_flush?
      return false
    end

    def four_of_a_kind?
        for i in 0...13
            if @ranks[i] == 4
                return [8, i, -1, -1, -1, -1] # todo: get other card
            end
        end
        return false
    end

    def full_house?
        if three_of_a_kind?
            triple_high = three_of_a_kind?[1]
            (12).downto(0) do |i|
                if @ranks[i] >= 2
                    if i != triple_high
                        return [7, triple_high, i, -1, -1, -1]
                    end
                end
            end
        end
        return false
    end

    def flush?
       strToSuit = {'S'=>0, 'H'=>1, 'C'=>2, 'D'=>3}
       strToRank = {'2'=>0, '3'=>1, '4'=>2, '5'=>3, '6'=>4, '7'=>5, '8'=>6, '9'=>7, '10'=>8, 'J'=>9, 'Q'=>10, 'K'=>11, 'A'=>12}
       @suits.each do |suit|
           if suit >= 5
             score = [6]
             sorted_cards = @cards.sort_by{ |card| -strToRank[card.rank]}
             p sorted_cards
             sorted_cards.each do |card|
               score.append(strToRank(card.rank))
             end
             return score
           end
       end
       return false
    end

    def straight?
        straight_count = 0
        straight_high_card = -1
        # checks for 5+ consecutive cards in rank array
        for j in 0...13
            rankCt = @ranks[j]
            if rankCt != 0
                straight_count += 1
                if straight_count == 5
                    straight_high_card = j
                    for i in 1...3
                        if @ranks[i + j] > 0
                            straight_high_card = i+j
                        else
                            break
                        end
                    end
                    return [5, straight_high_card, -1, -1, -1, -1]
                end
            else
                straight_count = 0
            end
        end
        # Special case check for A,2,3,4,5 straight
        for i in 0...4
            if @ranks[i] == 0
                return false
            end
        end
        if @ranks[12] > 0
            return [5, 3, -1, -1, -1, -1]
        end
        return false
    end

    def three_of_a_kind?
        (12).downto(0) do |i|
            if @ranks[i] == 3
                return [4, i, -1, -1, -1, -1] # todo: get other cards
            end
        end
        return false
    end

    def two_pair?
        high_two_pair = -1
        low_two_pair = -1
        pairCount = 0
        (12).downto(0) do |i|
            if @ranks[i] == 2
                if pairCount == 0
                    high_two_pair = i
                elsif pairCount == 1
                    low_two_pair = i
                    return [3, high_two_pair, low_two_pair, -1, -1, -1] # todo: get other card
                end
                pairCount += 1
            end
        end
        return false
    end

    def pair?
        (12).downto(0) do |i|
            if @ranks[i] == 2
                return [2, i, -1, -1, -1, -1]
            end
        end
        return false
    end

    def highest_card?
        (12).downto(0) do |i|
            if @ranks[i] == 1
                return [1, i, -1, -1, -1, -1]
            end
        end
        return false
    end

    def empty_hand?
    end


    "OPS = [
        ['Royal Flush',     :royal_flush? ],
        ['Straight Flush',  :straight_flush? ],
        ['Four of a kind',  :four_of_a_kind? ],
        ['Full house',      :full_house? ],
        ['Flush',           :flush? ],
        ['Straight',        :straight? ],
        ['Three of a kind', :three_of_a_kind?],
        ['Two pair',        :two_pair? ],
        ['Pair',            :pair? ],
        ['Highest Card',    :highest_card? ],
        ['Empty Hand',      :empty_hand? ],

      end"

      # Returns the verbose hand rating
      #
      #     PokerHand.new("4s 5h 6c 7d 8s").hand_rating     # => "Straight"
      def hand_rating
        OPS.map { |op|
          (method(op[1]).call()) ? op[0] : false
        }.find { |v| v }
      end
end
