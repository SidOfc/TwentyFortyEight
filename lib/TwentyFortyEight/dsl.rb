# frozen_string_literal: true
module TwentyFortyEight
  # Dsl
  class Dsl
    attr_reader :settings, :game

    def initialize(settings = {}, &block)
      @callable = block
      @settings = settings
    end

    def apply(game)
      @queue = []
      @game  = game.dup

      instance_eval(&@callable)
    end

    def method_missing(sym, *args, &block)
      return sym if game.action(sym, insert: false).changed?
    end

    def respond_to_missing?(sym, *args, &block)
      true
    end
  end
end
