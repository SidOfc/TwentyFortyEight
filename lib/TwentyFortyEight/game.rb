# frozen_string_literal: true
module TwentyFortyEight
  # Game
  class Game
    attr_reader :id, :board, :settings, :score, :prev_score, :prev_available,
                :move_count, :log, :current_dir

    SETTINGS = { size: 4, fill: 0, empty: 0 }.freeze
    MOVES    = [:up, :down, :left, :right].freeze
    ACTIONS  = [*MOVES, :quit].freeze

    def initialize(id = 1, opts = {}, **rest_opts)
      @id             = id
      @score          = 0
      @prev_score     = 0
      @move_count     = 0
      @settings       = Options.new SETTINGS.merge(opts).merge(rest_opts)
      @board          = Board.new(settings)
      @prev_available = available
      @current_dir    = nil
      @force_quit     = false
      @log            = Logger.new if settings.log?
      2.times { insert! } unless settings.board?
    end

    def insert!
      value = Random.rand(1..10) == 10 ? 4 : 2
      pos   = available.sample

      board.set! value, pos if pos
    end

    def changed?
      score > prev_score || (prev_available - available).any?
    end

    def won?
      board.flatten.max >= 2048
    end

    def lost?
      true if end? && !won?
    end

    def quit!
      @force_quit = true
    end

    def end?
      true if @force_quit || !mergeable? && board.full?
    end

    def mergeable?
      directions.select { |dir| dup.move(dir, insert: false).changed? }.any?
    end

    def directions
      MOVES
    end

    def available
      board.empty_cells
    end

    def action(action, **opts)
      action == :quit && quit! || move(action, opts)
      self
    end

    def move(dir, **opts)
      return self unless directions.include? dir.to_sym

      @prev_score     = score
      @prev_available = available
      @current_dir    = dir

      send dir

      if changed?
        @move_count += 1

        log << { move: move_count, score: score, direction: dir } if log
        insert! unless opts[:insert] == false
      end

      self
    end

    def up
      board.transpose! && left && board.transpose!
    end

    def down
      board.transpose! && right && board.transpose!
    end

    def left
      board.replace! board.to_a.map { |col| merge(col) }
    end

    def right
      board.replace! board.to_a.map { |col| merge(col.reverse).reverse }
    end

    def dup
      TwentyFortyEight::Game.new settings.merge(board: board.to_a)
    end

    private

    def merge(unmerged)
      input  = unmerged.reject { |v| settings.empty? v }
      output = []

      while (current = input.shift)
        compare = input.shift

        if current == compare
          merged  = current << 1
          @score += merged
          output << merged
        else
          output << current
          break unless compare
          input.unshift compare if compare
        end

      end

      output.concat(Array.new(unmerged.size - output.size) { settings.empty })
    end
  end
end
