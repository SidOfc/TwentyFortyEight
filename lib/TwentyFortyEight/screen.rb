# frozen_string_literal: true
module TwentyFortyEight
  # Screen
  module Screen
    COLOR_MAP = {
      # white
      255 => [7, 7],
      # green
      70 => [7, 70], 34 => [7, 34], 28 => [7, 28], 22 => [7, 22],
      # blue
      39 => [7, 39], 33 => [7, 33], 27 => [7, 27], 21 => [7, 21],
      # magenta
      134 => [7, 134], 128 => [7, 128], 91 => [7, 91], 45 => [7, 54],
      # red
      196 => [7, 196], 160 => [7, 160], 124 => [7, 124],
      # orange
      208 => [7, 208], 202 => [7, 202], 166 => [7, 166],
      # yellow
      228 => [0, 228], 227 => [0, 227], 226 => [0, 226], 220 => [0, 220]
    }.freeze

    # create [tile val] => [color] map to color tiles
    COLOR_MAP_V = COLOR_MAP.keys.each_with_index.map do |color, shift|
      [(shift.zero? && shift || (1 << shift)), color]
    end.to_h.freeze

    CELL_PADDING = 10
    CELL_HEIGHT  = CELL_PADDING / 3
    HIST_WIDTH   = 15

    def self.init!(options = {})
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.nonl
      Curses.curs_set 0
      Curses.timeout = 0
      Curses.stdscr.keypad true

      init_colors! if Curses.has_colors?

      trap('SIGINT') { restore! && exit }
    end

    def self.restore!
      Curses.curs_set 1
      Curses.clear
      Curses.close_screen
    end

    def self.game_over(game, options = {})
      hist  = options[:history] || []
      info  = options[:info]    || []

      bw, hw, _hh, sy, sx = render_offsets hist, info, game.board.to_a

      render_game_over game, (sx - hw / 2), (sy + info.size)
    end

    def self.render(board, options = {})
      hist = options[:history] || []
      info = options[:info]    || []

      bw, hw, hh, sy, sx = render_offsets hist, info, board

      render_history hist, (sx + bw + 2 - hw / 2), sy, hw, hh if hist.any?
      render_info    info, (sx - hw / 2),          sy, bw     if info.any?

      render_board board, (sx - hw / 2), (sy + info.size)
      handle_keypress options[:interactive]

      Curses.refresh
    end

    def self.render_offsets(history, info, b)
      hist_size   = history.any? ? HIST_WIDTH : 0
      board_width = CELL_PADDING * b.size

      [board_width, hist_size, (b.size * CELL_HEIGHT + info.size),
       (Curses.lines / 2) - ((board_width / 2) / CELL_HEIGHT),
       (Curses.cols / 2) - (board_width / 2)]
    end

    def self.handle_keypress(allow_moves = true)
      case Curses.getch
      when ' ' then sleep 0.2 until Curses.getch == ' '
      when Curses::KEY_DOWN,  's', 'j' then :down  if allow_moves
      when Curses::KEY_UP,    'w', 'k' then :up    if allow_moves
      when Curses::KEY_LEFT,  'a', 'h' then :left  if allow_moves
      when Curses::KEY_RIGHT, 'd', 'l' then :right if allow_moves
      when Curses::KEY_CLOSE, 'q'      then :quit
      when 'r'                         then :restart
      end
    end

    def self.render_history(history, start_x, start_y, width = 15, size = 10)
      history.last(size).reverse.each_with_index do |game, y|
        Curses.setpos (start_y + y), start_x
        Curses.attron (Curses.color_pair(0)  | Curses::A_BOLD) do
          Curses.addstr justified_str("##{game.id}", game.score, width)
        end
      end
    end

    def self.render_info(info_rows, start_x, start_y, width)
      info_rows.each_with_index do |h, y|
        part_width = width / h.count
        h.each_with_index do |(label, value), x|
          xx = x > 0 ? 1 : 0
          Curses.setpos (start_y + y), start_x + xx + (x * part_width)
          Curses.attron (Curses.color_pair(0)  | Curses::A_BOLD) do
            Curses.addstr justified_str(label, value, (part_width - xx))
          end
        end
      end
    end

    def self.render_board(board, start_x, start_y)
      board.each_with_index do |col, y|
        current_y = start_y + y * CELL_HEIGHT
        col.each_with_index do |val, x|
          current_x = start_x + x * CELL_PADDING
          Curses.attron (Curses.color_pair(color_from_value(val)) | Curses::A_BOLD) do
            cell(val).each_with_index do |line, offset|
              Curses.setpos (current_y + offset), current_x
              Curses.addstr line
            end
          end
        end
      end
    end

    def self.render_game_over(game, start_x, start_y)
      size   = game.board.to_a.size
      width  = size * CELL_PADDING
      spacer = ''.center width
      lines  = ['Game over!', "score: #{game.score}", '', "[Q]uit", "[R]estart"]
      lines  = lines.map { |text| text.center width }
      rows   = (size * CELL_HEIGHT - lines.count).to_f

      (rows / 2).floor.times { lines.unshift spacer }
      (rows / 2).ceil.times { lines.push spacer }

      Curses.attron (Curses.color_pair(250) | Curses::A_BOLD) do
        lines.each_with_index do |line, offset|
          Curses.setpos (start_y + offset), start_x
          Curses.addstr line
        end
      end
    end

    def self.color_from_value(v)
      COLOR_MAP_V[v] || COLOR_MAP.keys.last
    end

    def self.cell(val, width = CELL_PADDING, fill_count = CELL_HEIGHT, r = 0)
      spacer     = ''.center width
      lines      = [(val > r ? val : '').to_s.center(width)]
      fill_count = fill_count > 1 ? fill_count - 1 : fill_count

      (fill_count / 2).ceil.times { lines.unshift spacer }
      (fill_count / 2).floor.times { lines.push spacer }

      lines
    end

    def self.justified_str(label, value, length, seperator = ': ')
      label_width = label.to_s.size + seperator.size
      "#{label}#{seperator}#{value.to_s.rjust length - label_width}"
    end

    def self.init_colors!
      Curses.start_color
      Curses.assume_default_colors -1, -1

      Curses.init_pair 250, 0, 7

      COLOR_MAP.each_with_index do |arr, i|
        Curses.init_pair arr[0], *arr[1]
      end
    end
  end
end
