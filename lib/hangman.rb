require_relative 'game.rb'
require 'time'


puts "Welcome to hangman!"
puts
while true
  puts "Select game mode: "
  puts "(N)ew game"
  puts "(L)oad game"
  valid = false
  while !valid
    input = gets.chomp.downcase
    case input
    when "n"
      game = Game.new
      valid = true
    when "l"
      game = Game.load
      valid = true
    else
      puts "Invalid selection"
    end
  end

  game.play
  puts "Play again? Y/n?"
  return unless gets.chomp.downcase == 'y'
end