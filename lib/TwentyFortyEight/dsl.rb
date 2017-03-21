# frozen_string_literal: true
module TwentyFortyEight
  # Dsl
  class Dsl
    attr_reader :settings, :game

    def initialize(game, settings = {}, &block)
      @callable = block
      @settings = settings
      @game     = game
    end

    def apply(game)
      @queue = []
      instance_eval(&@callable)
    end

    def quit!
      game.quit! && :quit
    end

    def method_missing(sym, *args, &block)
      return game.send(sym) if [:won?, :lost?, :changed?, :available,
                                :score, :prev_score].include?(sym)
      return sym if game.dup.action(sym, insert: false).changed?
    end

    def respond_to_missing?(sym, *args, &block)
      true
    end
  end
end
