# frozen_string_literal: true
module TwentyFortyEight
  # Board
  class Board
    attr_reader :board, :settings

    def initialize(opts = {})
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
      Board.new settings.merge(board: board.dup)
    end

    private

    def self.generate(**opts)
      Array.new(opts[:size]) do
        Array.new(opts[:size]) { opts[:fill] }
      end
    end
  end
end
