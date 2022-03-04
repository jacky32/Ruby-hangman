require 'csv'

class Game

  def initialize
    generate_save_file unless File.exist?('saves.csv')

    @player = Player.new
    start_game
  end

  def generate_save_file
    file = File.open('saves.csv', 'w')
    file.puts("'save_name','word','board','tries','misses'")
    file.close
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
      if guess.length > 4
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
      save_filename = option.split(' ')[1] #todo security
      @saves = CSV.open('saves.csv', mode = "w", headers: true, header_converters: :symbol) do |row|
        row[:save_name] = save_filename
        row[:word] = @word
        row[:board] = @board
        row[:tries] = @tries
        row[:misses] = @misses
        #row << save, ...
      end
    elsif option.split(' ')[0] == 'load'
      load_filename = option.split(' ')[1] #todo security
      @saves = CSV.open('saves.csv', headers: true, header_converters: :symbol) do |row|
        #row[:save_name] = save_filename
        @word = row[:word]
        @board = row[:board]
        @tries = row[:tries]
        @misses = row[:misses]
      end
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
