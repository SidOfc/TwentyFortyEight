# frozen_string_literal: true
module TwentyFortyEight
  # Cli
  module Cli
    def self.parse!(**user_defaults)
      mode     = ARGV[0].to_s.downcase.to_sym
      settings = defaults_for(mode).merge user_defaults
      settings[:mode] = mode
      settings[:mode] = :play unless TwentyFortyEight.modes.include? mode

      OptionParser.new do |cli|
        cli.banner = "2048 [mode] [options]"

        cli.separator "options:"

        cli.on('-i', '--interactive', 'Can you reach the 2048 tile?') do
          settings[:interactive] = true
        end

        cli.on('-eX,Y,Z', '--exclude=X,Y,Z', Array,
               'Exclude directions') do |list|
          settings[:except] = list.map(&:to_sym)
        end

        cli.on('-oX,Y,Z', '--only=X,Y,Z', Array,
               'Include directions') do |list|
          settings[:only] = list.map(&:to_sym)
        end

        cli.on('-dMS', '--delay=MS', Float,
               'Delay in ms, applied after each move') do |ms|
          settings[:delay] = ms
        end

        cli.on('-aSOLVER', '--a=SOLVER', String,
               'Specify a solver to play the game') do |solver|
          settings[:solver] = solver.to_sym
        end

        cli.on('-sSIZE', '--size=SIZE', Integer,
               'Set grid size of the board') do |size|
          settings[:size] = size
        end

        cli.on('-l', '--log', 'Log game moves in json format') do |v|
          settings[:log] = v
        end

        cli.on('-h', '--history', 'Show game history') do |v|
          settings[:history] = v
        end

        cli.on('-v', '--[no-]verbose', 'Toggles printing the game') do |v|
          settings[:verbose] = v
        end

        cli.on('--help', 'Display this help') do
          puts cli
          exit 0
        end
      end.parse!

      settings.delete :only if settings[:except]
      settings.delete :except if settings[:only]

      Options.new settings
    end

    def self.defaults_for(mode)
      case mode.to_sym
      when :endless
        { verbose: true, delay: 100 }
      when :play
        { verbose: true, delay: 100 }
      else
        { verbose: true, interactive: true, delay: 10 }
      end
    end

    class UnknownModeError < StandardError; end
  end
end
