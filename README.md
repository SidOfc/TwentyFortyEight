# TwentyFortyEight
Play a game of 2048 in your terminal, there are options that allow you to do various things such as log the moves of a game using `-l`, letting it auto-play endlessly using mode `endless`, and optionally record history using `-h` (only useful in `endless` mode).

The game is played using either the **arrow keys**, **W**, **A**, **S**, **D** or the vim keys: **K**, **H**, **J**, **L**. After a game has ended, you will be prompted to press either **Q** or **R**. pressing **Q** exits the command completely.

## Status

![Licence](https://img.shields.io/badge/license-MIT-E9573F.svg)
[![Gem Version](https://img.shields.io/gem/v/TwentyFortyEight.svg?colorB=E9573F&style=square)](rubygems.org/gems/TwentyFortyEight)
[![Issues](https://img.shields.io/github/issues/SidOfc/TwentyFortyEight.svg)](https://github.com/SidOfc/TwentyFortyEight/issues)
[![Build Status](https://img.shields.io/travis/SidOfc/TwentyFortyEight.svg)](https://travis-ci.org/SidOfc/TwentyFortyEight)
[![Coverage Status](https://img.shields.io/coveralls/SidOfc/TwentyFortyEight.svg)](https://coveralls.io/github/SidOfc/TwentyFortyEight?branch=master)

---

## Changelog

_dates are in dd-mm-yyyy format_

#### 08-12-2017 VERSION 0.2.2

- Logger no longer throws exceptions if no `logs` dir exists in the current working directory.

#### 24-03-2017 VERSION 0.2.1

- Fixed `TwentyFortyEight::Game#won?` method, it no longer causes an exception
- Added tests for core components
- Updated some gemspec info
- Added config files for travis CI and Coveralls
- Added more defaults
  - `TwentyFortyEight::Board` now has `{ size: 4, fill: 0, empty: 0 }` as defaults
  - `TwentyFortyEight::Cli` now has the _history_ option enabled by default in _endless_ mode
- `TwentyFortyEight::Logger` can now `load!` an existing log file
- Added `sequence` method to `TwentyFortyEight::Dsl` which allows you to either execute a sequence of moves completely, or not at all

#### 22-03-2017 VERSION 0.2.0

- Highscore is stored in a file
  - each fieldsize has it's own highscore
- Added vim keykinds
  - Added keybinds to the `--help` flag
- Only 'relevant' info is shown in a specified game mode
  - Removed display of 'id' from the 'play' mode
- Removed solver option completely

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'TwentyFortyEight'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install TwentyFortyEight
```

## Usage

The game will store a highscore for each field size played. This means that playing a 4x4 will show a different highscore then playing a 5x5. The file in which this is stored can be found at `~/.2048`, it will contain these scores in the JSON format.

### From the commandline

To simply play a game:

```
$ 2048
```

To let it automatically play using the predefined order: `:left`, `:down`, `:right`, `:up`

```
$ 2048 play
```

Need help?

```
$ 2048 --help
```

### General

After installing the gem globally or in your application you'll have to `require` the gem before being able to use it.

```ruby
require 'TwentyFortyEight'
```

When the gem is loaded, you can proceed to call one of the following methods:

* `TwentyFortyEight#play options = { size: 4, fill: 0, empty: 0 }, &block`
* `TwentyFortyEight#endless options = { size: 4, fill: 0, empty: 0 }, &block`

The options can be a hash containing any of the options available to the CLI.
This means you can set the following keys:

* `:interactive` - A `Boolean` indicating wether or not to play the game manually (thereby printing the game as well regardless of `:verbose`)
* `:exclude` - An `Array` of directions to exclude by default when playing the game. Once the remaining moves become unavailable, all moves will be allowed for use to get unstuck
* `:only` - The opposite of `:exclude`
* `:delay` - An `Integer` representing a delay in milliseconds to `sleep` between each move
* `:size` - An `Integer` representing the size of the board, default 4
* `:log` - A `Boolean` indicating wether or not to save a log file to `./logs`
* `:history` - A `Boolean` indicating wether or not to show a game history log next to the game
* `:verbose` - A `Boolean` indicating wether or not to display the game, overridden when `:interactive` is `true`

When the game ends, the `TwentyFortyEight::Game` instance will be returned.
This object contains all the information there is about the game, it will also contain an accessible _log_ if `:log` is set to `true`.

The returned object has the following useful calls:

* `Game#won?` - Returns a `Boolean` result of wether the highest tile was `> 2048`
* `Game#lost?` - Opposite of `Game#won?`
* `Game#end?` - Returns a `Boolean` which tells you if the game has properly ended (unmergeable and board full)
* `Game#log` - Returns an instance of `TwentyFortyEight::Logger`, a simple wrapper class containing an array of entries accessible through `Logger#entries`
* `Game#score` - Returns an `Integer` representing the final score of the game

### Connect your script!

You can also connect your script to the game. A block can also be passed to `TwentyFortyEight#play` and `TwentyFortyEight#endless`.
Within that block, all you need to do is return a direction. There is a small DSL within that allows you to do moves based on availability.
With that, you can create simple patterns, e.g:

```ruby
require 'TwentyFortyEight'

game = TwentyFortyEight.play log: true do
  left || down || right || up
end

puts game.score # => 2345
puts game.log.entries # => [{... log: 'entry' ...}, [{...}, {...}]]
puts game.won? # => false
puts game.end? # => true
```

### The DSL

A small DSL built into the game allows for easier creation of patterns. A small example:

```ruby
require 'TwentyFortyEight'

game = TwentyFortyEight.play do
  left || down || right || up
end
```

What the above does is copy the current state of the game, execute the move on the copy and return the direction if the board changed or nothing (`nil`) otherwise. The `||` statements will continue to the next expression until something returns truthy. If no move is possible the game will simply end.

The problem with this setup is that there is no real way of adding complex patterns, you can basically only chain those 4 in different orders to eventually create a maximum of 16 patterns.

#### Helpers

Below is a list of helpers available within the _block_ passed to the game:

|         helper        |                    description                |
|-----------------------|-----------------------------------------------|
|`left`                 | returns `:left` if possible, otherwise `nil`  |
|`right`                | returns `:right` if possible, otherwise `nil` |
|`up`                   | returns `:up` if possible, otherwise `nil`    |
|`down`                 | returns `:down` if possible, otherwise `nil`  |
|`sequence(*dir_syms)`  | attempts to execute each move consecutively, if all change the game the pattern will be executed else `nil` is returned. |
|`available`            | an `Array` of `Hash`es, each containing `:x` and `:y` keys that represent an empty tile in the current board. |
|`score`                | the current score |
|`prev_score`           | the previous score (before last move was executed) |
|`changed?`             | wether the board changed since last turn (the move helpers (`sequence`, `left`, `right`, `up` and `down`) do this for you) |
|`won?`                 | wether you beat the game by achieving the `2048` tile |
|`lost?`                | you'll have lost if you can no longer merge and the board is full |
|`quit!`                | force quit the game |

#### Code examples

The following will give you some insight on how to get started and what goes on in the background.

##### Overview

```ruby
require 'TwentyFortyEight'

game = TwentyFortyEight.play do
  left                    # => :left or nil
  right                   # => :right or nil
  up                      # => :up or nil
  down                    # => :right or nil
  sequence :down, :left   # => the next direction until the end has been reached
  available               # => [{ x: 0, y: 0 }, { x: 1, y: 1 }, ...]
  score                   # => 2222
  won?                    # => true or false
  changed?                # => true or false
  lost?                   # => true or false
  quit!                   # => :quit
end
```

##### Simple pattern

executes in order:

1. `:left` else
2. `:down` else
3. `:right` else
4. `:up`

```ruby
require 'TwentyFortyEight'

game = TwentyFortyEight.play do
  left || down || right || up
end
```

#### Sequences

executes in order:

1. `:down` twice, `:left` twice else
2. `:down` and `:left` else
3. `:down` and `:right` else
4. `:right` and `:left` else
5. `:left` else
6. `:down` else
7. `:right` else
8. `:up`

```ruby
require 'TwentyFortyEight'

game = TwentyFortyEight.play do
  sequence(:down, :down, :left, :left) ||
  sequence(:down, :left) ||
  sequence(:down, :right) ||
  sequence(:right, :left) ||
  left || down || right || up # => to not get stuck
end
```

## Roadmap

* Improve logging options

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Sidney Liebrand/TwentyFortyEight. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
