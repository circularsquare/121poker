class Handjudge

    def init(cards)
        @cards = cards
        judge()
    end

    def judge()
        strToRank = {'2'=>0, '3'=>1, '4'=>2, '5'=>3, '6'=>4, '7'=>5, '8'=>6, '9'=>7, '10'=>8, 'J'=>9, 'Q'=>10, 'K'=>11, 'A'=>12}
        strToSuit = {'S'=>0, 'H'=>1, 'C'=>2, 'D'=>3}
        @ranks = Array.new(13,0)
        @suits = Array.new(4,0) # suit order spade, heart, club, diamond
        for i in 0...7
            card = @cards[i]
            # put string information for cards into format for array
            map_rank = strToRank[:card.rank]
            map_suit = strToSuit[:card.suit]
            # increment appropriate array counts for each card
            @ranks[map_rank] += 1
            @suits[map_suit] += 1
        end
    end

    def royal_flush?
    end

    def straight_flush?
    end

    def four_of_a_kind?
        @four_card = -1
        for i in 0...13
            if @ranks[i] == 4
                @four_card = i
                return true
            end
        end
        return false
    end
    
    def full_house?
        @full_house_pair = -1
        if three_of_a_kind
            (12).downto(0) do |i|
                if @ranks[i] >= 2
                    if i != @triple_high
                        @full_house_pair = i
                        return true
                    end
                end
            end
        end
        return false
    end

    def flush?
       @suits.each do |suit|
           if suit >= 5
            return true
           end 
       end
       return false
    end

    def straight?
        straight_count = 0
        @straight_high_card = -1
        # checks for 5+ consecutive cards in rank array
        for j in 0...13
            rankCt = @ranks[j]
            if rankCt != 0
                straight_count += 1
                if straight_count == 5
                    @straight_high_card = j
                    for i in 1...3
                        if @ranks[i + j] > 0
                            @straight_high_card = i+j
                        else
                            break
                        end
                    end
                    return true
                end
            else
                straight_count = 0
            end
        end
        # Special case check for A,2,3,4,5 straight
        for i in 0...4
            if @ranks[i] > 0
                straight_count += 1
            else
                break
            end
            if @ranks[12] > 0
                @straight_high_card = 3 # position of card 5 in the rank array
                return true
        end
        return false
    end

    def three_of_a_kind?
        @triple_high = -1
        (12).downto(0) do |i|
            if @ranks[i] == 3
                @triple_high = i
                return true
            end
        end
        return false
    end

    def two_pair?
        @high_two_pair = -1
        @low_two_pair = -1
        pairCount = 0
        (12).downto(0) do |i|
            if @ranks[i] == 2
                if pairCount == 0
                    @high_two_pair = i
                elsif pairCount == 1
                    @low_two_pair = i
                    return true
                pairCount += 1
                end
            end
        end
        return false
    end

    def pair?
        @only_pair = -1
        (12).downto(0) do |i|
            if @ranks[i] == 2
                @only_pair = i
                return true
            end
        end
        return false
    end

    def highest_card?
        (12).downto(0) do |i|
            if @ranks[i] == 1
                return i
            end
        end
    end

    def empty_hand?
    end
  

    OPS = [
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
      ]
    
      # Returns the verbose hand rating
      #
      #     PokerHand.new("4s 5h 6c 7d 8s").hand_rating     # => "Straight"
      def hand_rating
        OPS.map { |op|
          (method(op[1]).call()) ? op[0] : false
        }.find { |v| v }
      end
    
end  