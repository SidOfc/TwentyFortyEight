require "spec_helper"

RSpec.describe TwentyFortyEight::Game do
  it 'Can move down' do
    game = TwentyFortyEight::Game.new board: [[2, 2, 2, 2],
                                              [0, 0, 0, 0],
                                              [0, 0, 0, 0],
                                              [0, 0, 0, 0]]
    game.move :down, insert: false

    expect(game.board.board[3][0]).to eq 2
    expect(game.board.board[3][1]).to eq 2
    expect(game.board.board[3][2]).to eq 2
    expect(game.board.board[3][3]).to eq 2
  end

  it 'Can move up' do
    game = TwentyFortyEight::Game.new board: [[0, 0, 0, 0],
                                              [0, 0, 0, 0],
                                              [0, 0, 0, 0],
                                              [2, 2, 2, 2]]
    game.move :up, insert: false

    expect(game.board.board[0][0]).to eq 2
    expect(game.board.board[0][1]).to eq 2
    expect(game.board.board[0][2]).to eq 2
    expect(game.board.board[0][3]).to eq 2
  end

  it 'Can move left' do
    game = TwentyFortyEight::Game.new board: [[0, 0, 0, 2],
                                              [0, 0, 0, 2],
                                              [0, 0, 0, 2],
                                              [0, 0, 0, 2]]
    game.move :left, insert: false

    expect(game.board.board[0][0]).to eq 2
    expect(game.board.board[1][0]).to eq 2
    expect(game.board.board[2][0]).to eq 2
    expect(game.board.board[3][0]).to eq 2
  end

  it 'Can move right' do
    game = TwentyFortyEight::Game.new board: [[2, 0, 0, 0],
                                              [2, 0, 0, 0],
                                              [2, 0, 0, 0],
                                              [2, 0, 0, 0]]
    game.move :right, insert: false

    expect(game.board.board[0][3]).to eq 2
    expect(game.board.board[1][3]).to eq 2
    expect(game.board.board[2][3]).to eq 2
    expect(game.board.board[3][3]).to eq 2
  end
  it 'Inserts a tile after a move' do
    game = TwentyFortyEight::Game.new board: [[0, 0, 0, 0],
                                              [0, 0, 8, 0],
                                              [0, 4, 0, 0],
                                              [2, 0, 0, 0]]
    prev = game.board.empty_cells.count

    game.move :down

    expect(game.board.empty_cells.count).to be < prev
  end

  it 'Can determine a win' do
    game = TwentyFortyEight::Game.new board: [[0, 0, 0, 0],
                                              [0, 0, 8, 0],
                                              [0, 4, 0, 0],
                                              [2, 0, 2048, 0]]

    expect(game.won?).to be true
  end

  it 'Can determine a lose' do
    game = TwentyFortyEight::Game.new board: [[2, 8, 4, 2],
                                              [4, 2, 8, 4],
                                              [8, 4, 2, 8],
                                              [2, 8, 4, 2]]

    expect(game.lost?).to be true
  end

  it 'Can determine a game over' do
    game = TwentyFortyEight::Game.new board: [[2, 8, 4, 2],
                                              [4, 2, 8, 4],
                                              [8, 4, 2, 8],
                                              [2, 8, 4, 2]]
    game2 = TwentyFortyEight::Game.new board: [[2, 8, 4, 2],
                                               [4, 2, 8, 4],
                                               [8, 4, 4, 8],
                                               [2, 8, 4, 2]]

    expect(game.end?).to  be_truthy
    expect(game2.end?).to be_falsey
  end

  it 'Performs a correct single merge' do
    game = TwentyFortyEight::Game.new board: [[0, 0, 0, 0],
                                              [0, 0, 0, 0],
                                              [2, 0, 0, 0],
                                              [2, 0, 0, 0]]
    game.move :down, insert: false

    expect(game.board.board[2][0]).to eq 0
    expect(game.board.board[3][0]).to eq 4
  end

  it 'Performs a correct double merge' do
    game = TwentyFortyEight::Game.new board: [[2, 0, 0, 0],
                                              [2, 0, 0, 0],
                                              [2, 0, 0, 0],
                                              [2, 0, 0, 0]]
    game.move :down, insert: false

    expect(game.board.board[0][0]).to eq 0
    expect(game.board.board[1][0]).to eq 0
    expect(game.board.board[2][0]).to eq 4
    expect(game.board.board[3][0]).to eq 4
  end

  it 'Does not merge unequal tiles' do
    game = TwentyFortyEight::Game.new board: [[0, 0, 0, 0],
                                              [0, 0, 0, 0],
                                              [2, 0, 0, 0],
                                              [4, 0, 0, 0]]
    game.move :down, insert: false

    expect(game.board.board[2][0]).to eq 2
    expect(game.board.board[3][0]).to eq 4
  end
end
