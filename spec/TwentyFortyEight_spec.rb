require "spec_helper"

RSpec.describe TwentyFortyEight do
  it 'Can play a game' do
    game = TwentyFortyEight.play

    expect(game.end?).to  be true
    expect(game.score).to be > 0
    expect(game.moves).to be > 0
  end
end
