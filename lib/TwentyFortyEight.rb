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
  MODES    = [:play, :endless].freeze
  SETTINGS = { size: 4, fill: 0, empty: 0 }.freeze

  @@games     = []
  @@highscore = nil

  def self.play(settings = {}, &block)
    settings = Options.new SETTINGS.merge(settings)
    game     = Game.new @@games.count, settings
    dirs     = game.directions - (settings.except || [])
    dirs    -= (settings.only || [])
    dsl      = Dsl.new game, settings, &block if block_given?

    load_or_set_highscore!(game.score, settings) unless @@highscore

    Screen.init! settings if settings.verbose? && @@games.empty?

    trap 'SIGINT' do
      Screen.restore! if settings.verbose?
      exit
    end

    restart      = false
    non_blocking = dirs

    render_game game, settings if settings.verbose?

    loop do
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
        load_or_set_highscore! game.score, settings
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

  def self.load_or_set_highscore!(current_score, settings, path = '~/.2048')
    @@highscore                     ||= load_highscore
    @@highscore[settings.size.to_s] ||= 0

    return unless current_score > @@highscore[settings.size.to_s]

    @@highscore[settings.size.to_s] = current_score
    write_highscore
  end

  def self.write_highscore(path = '~/.2048')
    File.write File.expand_path(path), @@highscore.to_json
  end

  def self.load_highscore(path = '~/.2048')
    path = File.expand_path path

    if File.exists?(path)
      contents = File.read path
      hsh      = JSON.parse contents.start_with?('{') && contents || '{}'
    else
      File.new path, File::CREAT
      {}
    end
  end

  def self.endless(settings = {}, &block)
    loop { TwentyFortyEight.play settings, &block }
  ensure
    Screen.restore! if settings.verbose?
  end

  def self.render_game(game, settings, final = false)
    h = { interactive: settings.interactive?, info: [] }

    h[:info] << { game: (1 + game.id) } if settings.mode? :endless
    h[:info] << { highscore: @@highscore[settings.size.to_s], move: game.moves }
    h[:info] << { score: game.score, dir: game.current_dir}
    h[:history] = (@@games + [game]) if settings.history?

    return Screen.game_over game, h if final
    Screen.render game.board.to_a, h
  end
end
