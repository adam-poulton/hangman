require_relative 'game.rb'
require 'time'

def save(game)
  Dir.mkdir("saves") unless Dir.exists?("saves")
  savename = "#{Time.new.strftime("%Y-%m-%d_%H-%M-%S")}.yaml"
  filename = "saves/#{savename}"
  puts "Saving game...#{savename}"
  File.open(filename, 'w') do |file|
    file.print game.to_yaml
  end
  puts "Game saved"
end

def load
  saves = Dir.children("saves") if Dir.exists?("saves")
  if saves
    save = get_save_input(saves)
    puts "Loading save...#{saves[save]}"
    game = Game.from_yaml(File.read(saves[save]))
  else
    puts "No saves available...Creating new game"
    game = Game.new
  end
  game
end

def get_save_input(saves)
  puts "# Available saves #"
  saves.each_with_index do |file, index|
    puts "#{index}. #{file}"
  end
  valid = false
  while !valid
    puts "Enter save number: "
    input = gets.chomp.to_i
    reg = /^[0-9]/ =~ input
    valid = !reg.nil? && input >= 0 && input < saves.length
    if !valid
      puts "ERROR: Invalid save number!"
    end
  end
  input
end

g = Game.new
g.play

