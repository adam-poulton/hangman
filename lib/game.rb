require 'yaml'

class Game
  attr_reader :answer, :guesses, :max_turns
  attr_accessor :turn

  def initialize(answer = random_answer, guesses = [], turn = 0, max_turns = 12)
    @answer = answer
    @guesses = guesses
    @turn = turn.to_i
    @max_turns = max_turns.to_i
  end

  def guess(input)
    guesses << input.downcase unless guesses.include?(input.downcase)
  end

  def display_answer
    answer.split("").map{ |char| guesses.include?(char) ? char : "_" }.join(" ")
  end

  def get_input
    valid = false
    while !valid
      puts "Enter a guess: "
      input = gets.chomp.downcase
      reg = /^[a-z]{1}$/ =~ input
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

  def play
    puts "Welcome to hangman"
    while turn < max_turns
      self.turn += 1
      puts "Round #{turn} of #{max_turns}"
      puts
      puts display_answer
      puts
      puts "Guesses: #{guesses.join(", ")}"
      guess(get_input)
    end
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
    words.filter{ |word| word.length >= 5 && word.length <= 12 }.sample.downcase
  end
end
