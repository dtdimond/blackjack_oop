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
    players.each do |player|
      player.clear_hand
    end

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
    puts "#{name} has a #{self.get_hand_score}.\n\n"
  end

  def display_flop
    puts "#{name}'s draw: "
    display_hand
  end

  # player hits - draw a card
  def hit(deck)
    deck.deal_card(self)
  end

  def clear_hand
    self.hand = []
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

  #Check if busted
  def is_busted?
    return self.get_hand_score > 21
  end
end

class Dealer < Player
  def initialize
    @name = "Dealer"
    @hand = []
  end

  def display_flop
    puts "Dealer's first card is face-down"
    puts "Dealer's second card is #{hand[1].value} of #{hand[1].suit}\n\n"
  end
    
end

module WinLossEnum
  WIN = "win"
  LOSS = "loss"
  CHECK = "check"
end

class Blackjack
  attr_accessor :deck, :players, :wins, :losses, :win_state
  include WinLossEnum

  def initialize
    @deck = Deck.new(3)
    @players = [Dealer.new, Player.new("You")]
    @wins = 0
    @losses = 0
    @win_state = CHECK #flagged to WIN or LOSS on BJ/Bust
  end

  # main game engine starting point
  def start
    @win_state = CHECK # clear out win_state for new games
    get_player_name
    deck.deal_hand(players)
    show_flops
    player_turn
    dealer_turn
    check_winner
    play_again?
  end
  
  # prompts player for name
  def get_player_name
    if players[1].name == "You"
      puts "What's your name?"
      players[1].name = gets.chomp
      puts "Hey, #{players[1].name}. Let's play some blackjack.\n\n"
    end
  end

  # show the initially dealt cards
  def show_flops
    players.each do |player|
      player.display_flop
    end
  end

  # player's turn
  def player_turn
    do_hit_or_stay(players[1])
  end

  # dealer's turn - doesn't do it if player busted/blackjacked.
  def dealer_turn
    if win_state == CHECK
      do_hit_or_stay(players[0])
    end
  end

  # does the hit/stay process depending on who the player
  # is. keeps going until someone wins/loses or stays
  def do_hit_or_stay(player_or_dealer)
    if player_or_dealer.class == Dealer #dealer's turn
      while !is_bust_or_blackjack?(player_or_dealer)
        sleep(2) #makes output seem more human
        if player_or_dealer.get_hand_score < 17
          puts "Dealer score is #{player_or_dealer.get_hand_score}. Dealer must hit."
          player_or_dealer.hit(deck)
          player_or_dealer.display_hand
        else
          puts "Dealer score is #{player_or_dealer.get_hand_score}. Dealer must stay."
          player_or_dealer.display_hand
          break
        end
      end
    else #player's turn
      while !is_bust_or_blackjack?(player_or_dealer)
        response = prompt_hit_or_stay
        if response == "1"
          player_or_dealer.hit(deck)
          player_or_dealer.display_hand
        else
          puts "You stay." 
          player_or_dealer.display_hand
          break
        end
      end
    end
  end

  # helper function to prompt player for hit/stay
  def prompt_hit_or_stay
    puts "\nWould you like to (1) hit or (2) stay?"
    response = gets.chomp
    while response != "1" && response != "2"
      puts "Please choose either (1) for hit or (2) for stay."
      response = gets.chomp
    end
    return response
  end

  # checks to see if a player/dealer has busted or blackjackd
  def is_bust_or_blackjack?(player_or_dealer)
    # check for blackjack
    if player_or_dealer.get_hand_score == 21
      puts "Blackjack! #{player_or_dealer.name} wins!"
      player_or_dealer.display_hand
      player_or_dealer.class == Dealer ? @win_state = LOSS : @win_state = WIN
      return true
    # check for bust
    elsif player_or_dealer.get_hand_score > 21
      puts "Bust! #{player_or_dealer.name} loses!"
      player_or_dealer.display_hand
      player_or_dealer.class == Dealer ? @win_state = WIN : @win_state = LOSS
      return true
    # no blackjack or bust
    else
      return false
    end
  end

  # compares scores if no busts/blackjacks. Adds to wins/losses totals
  def check_winner
    if win_state == CHECK
      if players[0].get_hand_score >= players[1].get_hand_score
        self.win_state = LOSS
      else
        self.win_state = WIN
      end
    end

    if win_state == WIN
      self.wins = wins + 1 
      puts "Good win! You're now at #{wins} wins and #{losses}."
    else
      self.losses = losses + 1
      puts "Better luck next time. You're now at #{wins} wins and #{losses} losses."
    end
  end

  def play_again?
    puts "Would you like to play again? ('yes' to keep playing)."

    if gets.chomp == "yes"
      puts "\n\n********************************************"
      self.start
    else
      puts "See ya next time."
    end
  end

end

blackjack = Blackjack.new
blackjack.start
