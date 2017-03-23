# frozen_string_literal: true
module TwentyFortyEight
  # Board
  class Board
    attr_reader :board, :settings

    DEFAULTS = { size: 4, fill: 0, empty: 0 }

    def initialize(opts = {})
      opts             = Options.new DEFAULTS.merge(opts)
      @settings        = opts
      @settings[:size] = settings.board.size if settings.board?
      @board           = settings.board || Board.generate(settings)
    end

    def set!(value, **opts)
      @board[opts[:y]][opts[:x]] = value if opts[:x] && opts[:y]
    end

    def transpose!
      replace! board.transpose
    end

    def replace!(board_arr)
      @board = board_arr
    end

    def full?
      empty_cells.empty?
    end

    def to_a
      board
    end

    def empty_cells
      board.each_with_index.map do |col, y|
        col.each_with_index.map do |val, x|
          { x: x, y: y } if settings.empty? val
        end.compact
      end.flatten
    end

    def dup
      new settings.merge(board: board.dup)
    end

    private

    def self.generate(opts_hsh, **opts)
      opts = opts_hsh.merge opts
      Array.new(opts.size) { Array.new(opts.size) { opts.fill } }
    end
  end
end
