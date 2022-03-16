require 'json'

class Game

  def initialize
    @first_line_csv = "'save_name', 'word', 'board', 'tries', 'misses'"

    @player = Player.new
    start_game
  end

  def start_game
    @word = valid_word
    @tries = 0
    @misses = []
    set_board
    puts "Guess a letter!"
    gameloop
  end

  def gameloop
    while is_over != true
      guess = @player.guess_letter
      if guess.length > 3
        options(guess)
        next
      end
      check_guess(guess)
      print_board(guess)
    end
    start_game
  end

  def check_guess(guess)
    included = false
    @word.split('').each_with_index do |letter, index|
      if letter == guess
        @board[index] = letter
        included = true
      end
    end
    @tries += 1 if included == false
    @misses.push(guess) unless @misses.include?(guess) || included == true
  end

  def is_over
    if @word == @board.join
      puts "You won! The word was #{@word}."
      true
    elsif @tries >= 8
      puts "Out of tries, you lost! The word was #{@word}."
      true
    else
      false
    end
  end

  def set_board
    @board = @word.split('').map { |l| '_' }
  end

  def print_board(guess)
    puts
    puts @board.join(' ')
    puts
    puts "Tries: #{@tries}/8"
    puts "Guess: #{guess}"
    puts "Misses: #{@misses.join(', ')}"
  end

  def valid_word
    word_index = (0..10000).to_a.sample # select random index
    word = File.open('words.txt', 'r') do |f|
      (word_index-1).times { f.gets } # exclude n-1 words
      f.gets.chomp
    end

    if word.length >= 5 && word.length <= 12
      return word
    else
      valid_word
    end
  end

  def options(option)
    if option.split(' ')[0] == 'save'
      save = {
        "word" => @word,
        "board" => @board,
        "tries" => @tries,
        "misses" => @misses
      }
      File.open("save.json", 'w') { |f| f.write(save.to_json) }
    elsif option.split(' ')[0] == 'load'
      load = File.read("save.json")
      load_file = JSON.parse(load)
      @word = load_file["word"]
      @board = load_file["board"]
      @tries = load_file["tries"]
      @misses = load_file["misses"]
      print_board(' ') # print empty guess
    end
  end
end

class Player
  def guess_letter
    guess = gets.chomp.downcase
    unless guess.length == 1 && ('a'..'z').to_a.include?(guess) || guess.split(' ')[0] == 'save' || guess.split(' ')[0] == 'load'
      puts "Enter a letter!"
      guess_letter
    else
      return guess
    end
  end
end


Game.new
