require 'json'
require 'optparse'
require 'curses'
require_relative 'TwentyFortyEight/version'
require_relative 'TwentyFortyEight/options'
require_relative 'TwentyFortyEight/logger'
require_relative 'TwentyFortyEight/board'
require_relative 'TwentyFortyEight/game'
require_relative 'TwentyFortyEight/cli'
require_relative 'TwentyFortyEight/screen'
require_relative 'TwentyFortyEight/dsl'

module TwentyFortyEight
  @@games = []
  @@best  = nil

  def self.play(settings = {}, &block)
    settings = Options.new settings if settings.is_a? Hash
    game     = Game.new @@games.count, settings
    dirs     = game.directions - (settings.except || [])
    dirs     = dirs - (settings.only || [])
    dsl      = Dsl.new game, settings, &block if block_given?

    @@best ||= game

    Screen.init! settings if settings.verbose? && @@games.empty?

    trap 'SIGINT' do
      Screen.restore! if settings.verbose?
      exit
    end

    restart      = false
    non_blocking = dirs

    render_game game, settings if settings.verbose?

    loop do
      @@best = game if @@best != game && game.score > @@best.score
      # binding.pry
      if game.end?
        break if settings.mode?(:endless) ||
                 !settings.verbose? ||
                 !settings.interactive?
        render_game game, settings, true

        action = :default
        until [:quit, :restart].include? action
          action = Screen.handle_keypress
          sleep 0.1
        end

        restart = true if action == :restart
        break
      else
        if settings.interactive?
          action = Screen.handle_keypress until Game::ACTIONS.include?(action)
        else
          non_blocking = game.changed? ? dirs : non_blocking - [action]
          action       = dsl && dsl.apply(game.dup) || non_blocking.sample

          if non_blocking.empty?
            non_blocking.concat settings.except if settings.except?
            non_blocking.concat game.directions if settings.only?
          end
        end

        game.action action
        render_game game, settings if settings.verbose? || settings.interactive?
        sleep(settings.delay.to_f / 1000) if settings.delay?
      end
    end

    @@games << game

    if settings.log?
      game.log.write! dir: 'logs',
                      name: "2048-#{Time.now.to_i}-#{game.id}-#{game.score}"
    end

    return play(settings, &block) if restart

    game
  ensure
    Screen.restore! if settings.verbose? && settings.mode?(:play)
  end

  def self.endless(settings = {}, &block)
    settings = Options.new settings if settings.is_a? Hash
    loop { TwentyFortyEight.play settings, &block }
  ensure
    Screen.restore! if settings.verbose?
  end

  def self.modes
    (TwentyFortyEight.methods - [:modes, :render_game]) - Object.methods
  end

  def self.render_game(game, settings, final = false)
    print_extra = { interactive: settings.interactive?,
                    info: [{ highscore: @@best&.score},
                           { score: game.score, dir: game.current_dir},
                           { id: @@games.count, move: game.move_count }]}

    print_extra[:history] = (@@games + [game]) if settings.history?

    return Screen.game_over game, print_extra if final
    Screen.render game.board.to_a, print_extra
  end
end
