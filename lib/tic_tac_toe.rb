PROMPT = ">> "


def greeting
  puts "\n======================"
  puts   "Welcome to Tic Tac Toe"
  puts   "======================\n\n"
end


def get_names
  puts "Select Play Mode:"

  all_names = [["You", "Ruby"], ["You", "Friend"], ["Ruby", "Ruby"]]
  all_names.each_with_index do |name_array, index|
    puts "#{index+1}) #{name_array.join(' vs ')}"
  end

  print PROMPT

  while input = gets.chomp.to_i
    case input
    when 1
      @names = all_names[0]
      break
    when 2
      @names = all_names[1]
      break
    when 3
      name_array = []
      all_names[2].each_with_index do |name, index|
        name_array << "#{name} ##{index+1}"
      end
      @names = name_array
      break
    else
      puts "Please Select 1, 2 or 3"
      print PROMPT
    end
  end

  puts
end


def goes_first
  puts "Who Goes First?"
  @names.each_with_index do |name, index|
    puts "#{(index+1)}) #{name}"
  end
  print PROMPT

  while input = gets.chomp.to_i
    case input
    when 1
      break
    when 2
      @names = @names.reverse
      break
    else
      puts "Please Select 1 or 2"
      print PROMPT
    end
  end

  puts
end


def validate_letter(player_name)
  print "#{player_name} #{PROMPT}"
  input = gets.chomp

  until input.match(/[a-zA-Z]/) && input.length == 1 && @letters.first != input
    puts "Type ONE unique character for each player"
    print "#{player_name} #{PROMPT}"
    input = gets.chomp
  end

  @letters << input
end 


def choose_letters
  puts "Letters for #{@names.join(' and ')}?"
  @letters = []

  @names.each do |name|
    validate_letter(name)
  end

  puts
end


def choose_level
  puts "Game Level:"

  levels = ["easy", "medium", "hard"]
  levels.each_with_index do |level, index|
    puts "#{index+1}) #{level.capitalize}"
  end

  print PROMPT

  while input = gets.chomp.to_i
    case input
    when 1
      @game_level = levels[0]
      break
    when 2
      @game_level = levels[1]
      break
    when 3
      @game_level = levels[2]
      break         
    else
      puts "Please Select 1, 2 or 3"
      print PROMPT
    end
  end

end


def make_player_objects
  @players_init = []
  @names.zip(@letters).each do |array|
    if array[0].include?("Ruby")
      @players_init << Computer.new(array)
    else
      @players_init << Human.new(array)
    end
  end
end


class Game
  attr_reader   :players, :squares, :board, :level
  attr_accessor :winner

  def initialize(players, level)
    @players = players
    @squares =* (1..9)
    @level   = level
    @winner  = false
    @board   = Board.new
  end

  def captions(player)
    whos_turn  = "#{player.name}'s"
    info_label = "Turn (#{player.letter}) #{PROMPT}"
    if player.name == 'You'
      print "Your #{info_label}"
    else
      print "#{whos_turn} #{info_label}"
    end
  end

  def squares_remaining(numbers_array, pick)
    numbers_array.delete(pick.to_i)
  end

  def winner_test(player, game)
    if player.winning_sequences.include?("")
      game.winner = true
    end
  end

  def won_by(name)
    puts name == 'You' ? "YOU WIN!" : "#{name} wins"
    puts "Game Over"
  end

  def cats_eye
    puts "No winner\nTry again"
  end

end


class Board
  attr_accessor :spaces

  def initialize
    @spaces =* (1..9)
    draw(@spaces)
  end

  def draw(board_array)
    puts
    board_array.each_with_index do |space, index|
      if (index+1)%3 == 0
        print " #{space}\n"
        puts "---|---|---" if index != 8
      else
        print " #{space} |"
      end
    end
    puts
  end

  def redraw(number, letter)
    spaces.map! {|square| square.to_s.gsub(number,letter)}
    draw(spaces)
  end

end


class Player
  attr_reader :name, :letter
  attr_accessor :selected, :winning_sequences

  def initialize(array)
    @name     = array[0]
    @letter   = array[1]
    @selected = []
    @winning_sequences = ['123', '456', '789', '147', '258', '369', '159', '357']
  end

  def record_move(number, player_name)
    selected << number
    puts number if player_name.include?("Ruby")
  end

  def rewrite_win_seq(array, number)
    array.map! {|sequence| sequence.gsub(number,'')}
  end

  def rewrite_opp_win_seq(array, number)
    array.keep_if {|sequence| sequence if !sequence.include?(number)}
  end

end


class Human < Player

  def get_misc_pick(from_array)
    input = gets.chomp
    until from_array.include?(input.to_i)
      print "Try Again #{PROMPT}"
      input = gets.chomp
    end
    return input
  end

end


class Computer < Player

  def get_misc_pick(from_array)
    from_array.sample.to_s
  end

  def first_pick_medium(game_squares, opp_first)
    if opp_first != "5"
      "5"
    else
      get_misc_pick(game_squares)
    end
  end

  def first_pick_hard(opp_first)
    choices = ["1", "3", "5", "7", "9"]
    choices.delete(opp_first)
    choices.sample
  end

  def first_pick_helper(game, opp_first_select)
    if game.level == "medium"
      first_pick_medium(game.squares, opp_first_select)
    elsif game.level == "hard"
      first_pick_hard(opp_first_select)
    end
  end

  def filter_sequence(array, seq_length)
    array.select {|seq| seq if seq.length == seq_length}
  end

  def win_or_block(win_seq, opp_win_seq)
    win   = filter_sequence(win_seq, 1)
    block = filter_sequence(opp_win_seq, 1).sample
    if win.any?
      win.sample
    else
      block
    end
  end

  def next_pick_helper(best_choices)
    filtered_win_seq = filter_sequence(winning_sequences, 2).join("").split("")
    final_answer     = best_choices & filtered_win_seq
    if final_answer.length > 0
      final_answer.sample
    else
      filtered_win_seq.sample
    end
  end

  def next_pick(level)
    win_seq_squares = winning_sequences.join("").split("")
    best_choices    = win_seq_squares.select{ |number_string| win_seq_squares.count(number_string) > 1 }.uniq

    pick = win_seq_squares.sample if best_choices.empty?
    pick = best_choices.sample if level == "medium"
    pick = next_pick_helper(best_choices) if pick == nil
    return pick
  end

  def get_ruby_pick(opponent, game)
    combined_win_seq = winning_sequences + opponent.winning_sequences
    
    next_choice = first_pick_helper(game, opponent.selected.first) if selected.length == 0
    if game.squares.length == 7 && game.squares.include?(5)
      next_choice = '5'
    end
    next_choice = get_misc_pick(game.squares) if winning_sequences.empty?
    if filter_sequence(combined_win_seq, 1).length >= 1
      next_choice = win_or_block(winning_sequences, opponent.winning_sequences)
    end
    next_choice = next_pick(game.level) if next_choice == nil
    return next_choice
  end

end


def see_ya
  puts "\n=================="
  puts   "Thanks for Playing"
  puts   "==================\n\n"
end


def play_again
  puts "\nPlay Again?\n1) Yes\n2) No"
  print PROMPT

  while input = gets.chomp.to_i
    case input
    when 1
      tic_tac_toe
    when 2
      see_ya
      break    
    else
      puts "Please Select 1 or 2"
      print PROMPT
    end
    break
  end
end


def input_helper(player, opponent, game)
  if player.name.include?("Ruby") && game.level != "easy"
    player.get_ruby_pick(opponent, game)
  else
    player.get_misc_pick(game.squares)
  end
end


def get_opponent(players, index)
  if index == 0
    players[1]
  else
    players[0]
  end
end


def tic_tac_toe
  greeting
  get_names
  goes_first
  choose_letters
  choose_level if @names.join(" ").include?("Ruby")
  make_player_objects

  game = Game.new(@players_init, @game_level)

  loop do
    game.players.each_with_index do |player, index|
      game.captions(player)
      opponent = get_opponent(game.players, index)
      input = input_helper(player, opponent, game)
      player.record_move(input, player.name)
      game.squares_remaining(game.squares, input)      
      game.board.redraw(input, player.letter)
      player.rewrite_win_seq(player.winning_sequences, input)
      player.rewrite_opp_win_seq(opponent.winning_sequences, input)
      game.winner_test(player, game)
      game.won_by(player.name) if game.winner
      game.cats_eye if game.squares.empty? && game.winner == false
      break if game.winner || game.squares.empty?
    end
    break if game.winner || game.squares.empty?
  end

  play_again
end


tic_tac_toe

