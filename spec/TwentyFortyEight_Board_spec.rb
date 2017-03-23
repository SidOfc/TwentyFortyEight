require "spec_helper"

RSpec.describe TwentyFortyEight::Board do
  it 'Can create a board' do
    board    = TwentyFortyEight::Board.new size: 10
    set_size = board.settings.size
    flt_size = board.board.flatten.size

    expect(board.board).to be_kind_of Array
    expect(set_size).to    eq board.board.size
    expect(flt_size).to    eq (set_size * set_size)
  end

  it 'Can set a value' do
    board = TwentyFortyEight::Board.new size: 4

    board.set! 2, x: 1, y: 1

    expect(board.board[1][1]).to eq 2
  end

  it 'Can return empty cells' do
    board = TwentyFortyEight::Board.new size: 4, fill: 0, empty: 0

    board.set! 2, x: 1, y: 1

    expect(board.empty_cells).not_to include x: 1, y: 1
    expect(board.empty_cells).to     include x: 0, y: 0
    expect(board.empty_cells).to     include x: 3, y: 3
  end

  it 'Can check if it is full' do
    board = TwentyFortyEight::Board.new size: 5, empty: 0, fill: 2

    expect(board.full?).to be true
  end
end
