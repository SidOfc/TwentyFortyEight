require 'curses'

Curses.init_screen
Curses.start_color if Curses.has_colors?

# skip the terminal defined colors
offset = 0

# some default palettes
palettes = {
  red:     [196, 160, 124,  88],
  green:   [ 70,  34,  28,  22],
  blue:    [ 39,  33,  27,  21],
  orange:  [214, 208, 202, 166],
  magenta: [134, 128,  91,  54],
  yellow:  [228, 227, 226, 220]
}

# generate an overview of all colors from offset
[*offset..Curses.colors].each_slice(Curses.lines - 1) do |slice|
  palettes["c#{slice.min}_#{slice.max}"] = slice
end

# width of cell
palette_width   = 8

# horizontal spacing between palettes
palette_padding = 2

begin
  Curses.crmode
  Curses.noecho
  Curses.cbreak

  # initialize colors
  palettes.each do |color, shades|
    shades.each do |shade|
      Curses.init_pair shade, Curses::COLOR_WHITE, shade
    end
  end

  # display palettes
  palettes.each_with_index do |(color, shades), x|
    # set palette x
    posx = (palette_width + palette_padding) * x

    # print palette name
    Curses.setpos 0, posx
    Curses.addstr color.to_s.center(palette_width)

    # print each shade on the next line using the shade as background color
    # and white as foreground color
    shades.each_with_index do |shade, y|
      Curses.setpos (1 + y), posx
      Curses.attron Curses.color_pair(shade) do
        Curses.addstr shade.to_s.center(palette_width)
      end
    end
  end

  Curses.refresh
  sleep 0.2 until Curses.getch == ' '
ensure
  Curses.use_default_colors
  Curses.close_screen
end
