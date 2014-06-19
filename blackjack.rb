class Card
  attr_accessor :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def to_s
    "#{suit}, #{value}"
  end
end

class Deck
  attr_accessor :cards

  SUITS = ["diamonds", "hearts", "spades", "clubs"]
  VALUES = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]

  #Create the deck of cards
  def initialize(num_decks)
    #Init cards array
    @cards = []

    #Create a card for each suit/value combo
    SUITS.each do |suit|
      VALUES.each do |val|
        @cards << Card.new(suit, val)
      end
    end

    #Duplicate to make num_decks decks
    @cards = @cards * num_decks

    #shuffle the deck
    @cards.shuffle!
  end

  # Deals out the initial hand
  # 2 cards per each player
  def deal_hand(players)
    2.times do 
      players.each do |player|
        deal_card(player)
      end
    end
  end

  # Deals 1 card to a player
  def deal_card(player)
    if !self.is_empty?
        player.hand << cards.pop
      else
        self.initialize(1)
      end
  end

  #Checks if deck is empty
  def is_empty?
    return cards.length <= 0
  end

  def print_cards
    puts @cards
  end
end

class Player
  attr_accessor :hand, :name

  # Init
  def initialize(name)
    @hand = []
    @name = name
  end

  # print out contents of hand
  def display_hand
    hand.each do |card|
      puts "#{card.value} of #{card.suit}"
    end
  end

  # player hits - draw a card
  def hit(deck)
    deck.deal_card(self)
  end

  # Calculate score of the player's hand
  def get_hand_score
    score = 0
      
    # Add up score of non-aces
    values = hand.map{|card| card.value}
    values.each do |val|
      if Array(2..10).include?(val.to_i)
        score += val.to_i
      elsif ["J", "Q", "K"].include?(val)
        score += 10
      end
    end

    # deal with the aces
    values.count("A").times do
      if score + 11 <= 21
        score += 11
      else
        score += 1
      end
    end

    return score
  end
end

class Dealer < Player
  def hit_until_17(deck)
    # only hit if 16 or below
    if self.get_hand_score < 17
      while self.get_hand_score < 17
        puts "Dealer score: #{self.get_hand_score} is less than 17. Hitting..."
        self.hit(deck)

        self.display_hand
        puts "Dealer now at: #{self.get_hand_score}."
        puts
        sleep(1)
      end
    elsif self.get_hand_score < 22
      self.display_hand
      puts "Dealer stays with #{self.get_hand_score}."
      puts
    end
  end
end

  
d = Deck.new(2)
p1 = Player.new("Dan")
p2 = Dealer.new("dealer")

players = [p2, p1]
d.deal_hand(players)

players.each do |p|
  p.display_hand
  puts p.get_hand_score
end
p2.hit_until_17(d)
