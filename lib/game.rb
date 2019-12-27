require 'yaml'
require_relative 'hangman_ascii.rb'

class Game
  attr_reader :answer, :guesses, :max_turns
  attr_accessor :turn

  def initialize(answer = random_answer, guesses = [], turn = 1, max_turns = 12)
    @answer = answer
    @guesses = guesses
    @turn = turn.to_i
    @max_turns = max_turns.to_i
  end

  def guess(input)
    guesses << input.downcase unless guesses.include?(input.downcase)
    return 1 if !guesses.include?(input.downcase) && !answer.split("").include?(input.downcase)
    return 0 
  end

  def display_answer
    answer.split("").map{ |char| guesses.include?(char) ? char : "_" }.join(" ")
  end

  def display_hangman
    HANGMAN_ASCII[max_turns-turn]
  end

  def get_input
    valid = false
    while !valid
      puts "Enter a guess or 'save'"
      input = gets.chomp.downcase
      reg = /^[a-z]{1}$/ =~ input
      if input == 'save'
        return input
      end
      if reg.nil?
        puts "ERROR: Invalid input!"
      elsif guesses.include?(input)
        puts "ERROR: '#{input}' has already been guessed"
      else
        valid = true
      end
    end
    input
  end

  def save
    Dir.mkdir("saves") unless Dir.exists?("saves")
    savename = "#{Time.new.strftime("%Y-%m-%d_%H-%M-%S")}.yaml"
    filename = "saves/#{savename}"
    puts "Saving game...#{savename}"
    File.open(filename, 'w') do |file|
      file.print self.to_yaml
    end
    puts "Game saved"
  end

  def self.load
    saves = Dir.children("saves").sort.reverse if Dir.exists?("saves")
    if saves
      save = self.get_save_selection(saves)
      puts "Loading save..."
      game = self.from_yaml(File.read("saves/#{saves[save.to_i]}"))
    else
      puts "No saves available...Creating new game"
      game = self.new
    end
    game
  end

  def play
    while turn <= max_turns
      puts display_hangman
      puts
      puts display_answer
      puts
      puts "Guesses: #{guesses.join(", ")}"
      selection = get_input
      case selection
      when 'save'
        save
        return
      else
        self.turn += guess(selection)
      end
      if won?
        puts
        puts display_answer
        puts "***********"
        puts "WINNER!!!"
        puts "You correctly guessed: #{answer}"
        puts "***********"
        return
      end
    end
    if !won?
      puts display_hangman
      puts
      puts "You lost."
      puts "The answer was: #{answer}"
      puts
    end
  end

  def won?
    !display_answer.include?("_")
  end

  def self.get_save_selection(saves)
    puts "# Available saves #"
    saves.each_with_index do |file, index|
      puts "#{index}. #{file}"
    end
    valid = false
    while !valid
      puts "Enter save number: "
      input = gets.chomp
      reg = /^[0-9]/ =~ input
      input = input.to_i
      valid = !reg.nil? && input >= 0 && input < saves.length
      if !valid
        puts "ERROR: Invalid save number!"
      end
    end
    input
  end

  def to_yaml
    YAML.dump ({
      answer: @answer,
      guesses: @guesses,
      max_turns: @max_turns,
      turn: @turn
    })
  end

  def self.from_yaml(string)
    data = YAML.load(string)
    self.new(data[:answer], data[:guesses], data[:turn], data[:max_turns])
  end

  private

  def random_answer(file = "5desk.txt")
    words = File.open(file){ |data| data.readlines(chomp: true) }
    words.select{ |word| word.length >= 5 && word.length <= 12 }.sample.downcase
  end
end
