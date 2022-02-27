require "json"

class Hangman
  def initialize(word = select_word, guesses = 10, available_letters = "abcdefghijklmnopqrstuvwxyz", display_word = [])
    @word = word
    @display_word = display_word
    @guesses = guesses
    @available_letters = available_letters
  end

  def gameplay
    set_display_word if @display_word.length == 0

    while @guesses != 0
      display_round

      guess = get_guess
      @available_letters.delete!(guess)
      update_display_word(guess) if @word.include?(guess)

      display_found

      if win_check
        display_winner
        break
      end

      @guesses -= 1

      if @guesses == 0
        display_loser
        break
      end

      if save_check
        break
      end

      clear_screen
    end
  end

  def display_round
    puts ""
    puts "======= New Round ======="
    puts "You have #{@guesses} guesses left!"
    puts "========================="
    puts "#{@display_word.join("")}"
  end

  def display_found
    puts ""
    puts "====== Results ======="
    puts "#{@display_word.join("")}"
    puts "======================"
    puts ""
  end

  def display_winner
    puts ""
    puts "========================="
    puts "You win!"
    puts "The word was: #{@word}"
    puts "========================="
  end

  def display_loser
    puts ""
    puts "========================="
    puts "You lose!"
    puts "The word was: #{@word}"
    puts "========================="
  end

  def error_display(msg)
    puts ""
    puts "===== Try Again ====="
    case msg
    when "length"
      puts "Only enter one letter!"
    when "letters"
      puts "Only enter a letter!"
    when "guessed"
      puts "You've already guessed that letter!"
    end
    puts ""
  end

  def clear_screen
    system "clear" || "cls"
  end

  def get_guess
    loop do
      puts "Enter a letter to guess:"
      guess = gets.chomp.downcase

      if guess.length != 1
        error_display("length")
        next
      elsif !guess.match(/^[a-zA-Z]+$/)
        error_display("letters")
        next
      elsif !@available_letters.include?(guess)
        error_display("guessed")
        next
      else
        return guess
      end
    end
  end

  def get_save_name
    loop do
      puts "Enter your save file name, keep it under 10 characters please"
      save_name = gets.chomp
      return save_name if save_name.length < 10
    end
  end

  def save_check
    loop do
      puts "Would you like to save the game and quit?"
      puts "Enter q to save state and quit, anything else to continue playing"
      save = gets.chomp.downcase

      if save == "q"
        save_game
        return true
      end
      return false
    end
  end

  def save_game
    Dir.mkdir("save_files") unless Dir.exist?("save_files")

    save_name = get_save_name
    filename = "save_files/save.json"

    if File.exist?(filename)
      json = File.read(filename)
    else
      File.open(filename, "w") do |file|
        file.puts "[]"
      end
      json = File.read(filename)
    end

    save_state = {
      name: save_name,
      guesses: @guesses,
      word: @word,
      display_word: @display_word,
      available_letters: @available_letters,
    }

    File.open(filename, "w") do |file|
      file.puts JSON.pretty_generate(JSON.parse(json) << save_state)
    end
  end

  def update_display_word(guess_letter)
    @display_word.each_with_index do |letter, idx|
      if @word[idx] == guess_letter
        @display_word[idx] = guess_letter
      else
        next
      end
    end
  end

  def check_load
    puts "Would you like to start a new game, or load an existing one?"
    puts "Enter l to load a game, anything else to start a new game"
    choice = gets.chomp.downcase
    if choice == "l"
      game = load_game
      game.gameplay
    else
      gameplay
    end
  end

  def load_game
    file = 0
    if File.exist?("./save_files/save.json")
      puts "Here are the available save files"
      raw = File.read("./save_files/save.json")
    else
      puts ""
      puts "No save files found, starting a new game"
      return Hangman.new
    end

    formatted = JSON.parse(raw)
    formatted.each_with_index do |save_file, idx|
      puts "#{idx + 1}: #{save_file["name"]}"
    end

    puts "Enter the number of the file you'd like to load"
    loop do
      file = gets.chomp.to_i
      if file > 0 and file <= formatted.length
        break
      end
      puts ""
      puts "Enter a file number from the list above"
    end

    word, guesses, available_letters, display_word = formatted[file - 1].values_at("word", "guesses", "available_letters", "display_word")
    return Hangman.new(word, guesses, available_letters, display_word)
  end

  def win_check
    return @display_word.join() == @word
  end

  def set_display_word
    @display_word = Array.new(@word.length, "_")
  end

  def select_word
    file = File.open("./words.txt").readlines

    loop do
      word = file.sample.chomp
      if word.length > 4 and word.length < 13
        return word
      end
    end
  end
end

game = Hangman.new
game.check_load
