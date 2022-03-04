

class Game

  def initialize
    @player = Player.new
    start_game
  end

  def start_game
    @word = valid_word
    @tries = 0
    @misses = []
    set_board
    gameloop
  end

  def gameloop
    guess = @player.guess_letter
    @tries += 1
    check_guess(guess)
    print_board(guess)
    gameloop unless is_over
    start_game
  end

  def check_guess(guess)
    @word.split('').each_with_index do |letter, index|
      @board[index] = letter if letter == guess
    end
    @misses.push(guess) unless @misses.include?(guess)
  end

  def is_over
    if @word == @board.join
      true
    elsif @tries >= 8
      true
    else
      false
    end
  end

  def set_board
    @board = @word.split('').map { |l| '_' }
  end

  def print_board(guess)
    puts @board.join(' ')
    puts
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

end

class Player
  def guess_letter
    guess = gets.chomp.downcase
    guess_letter unless guess.length == 1 && ('a'..'z').to_a.include?(guess)
    return guess
  end
end


Game.new
