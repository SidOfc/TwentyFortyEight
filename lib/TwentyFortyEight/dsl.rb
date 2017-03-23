# frozen_string_literal: true
module TwentyFortyEight
  # Dsl
  class Dsl
    attr_reader :settings, :game

    def initialize(game, settings = {}, &block)
      @callable = block
      @sequence = []
      @settings = settings
      @game     = game
    end

    def apply(game)
      @queue = []
      instance_eval(&@callable)
    end

    def sequence(*directions)
      @sequence = directions.flatten.map(&:to_sym)
      run_sequence
    end

    def run_sequence
      return @poss.shift if @poss && @poss.any?

      copy   = @sequence.dup
      sample = game.dup
      @poss  = []

      while (next_move = copy.shift)
        unless sample.move(next_move).changed?
          @poss = nil
          break
        end

        @poss << next_move
      end

      @poss && @poss.shift
    end

    def info?(sym)
      [:won?, :lost?, :changed?, :available, :score, :prev_score].include? sym
    end

    def info(sym)
      game.send sym
    end

    def quit!
      game.quit! && :quit
    end

    def method_missing(sym, *args, &block)
      return info sym     if info? sym
      return sym          if game.dup.action(sym, insert: false).changed?
    end

    def respond_to_missing?(sym, *args, &block)
      true
    end
  end
end
