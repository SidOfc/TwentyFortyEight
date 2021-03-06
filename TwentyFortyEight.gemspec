# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/TwentyFortyEight/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.1'
  spec.name          = 'TwentyFortyEight'
  spec.version       = TwentyFortyEight::VERSION
  spec.authors       = ['Sidney Liebrand']
  spec.email         = ['sidneyliebrand@gmail.com']

  spec.summary       = %(A 2048 game for terminals)
  spec.description   = 'Play a game of 2048 in the terminal, colorized using ' \
                       'Ruby curses. (See --help for options / controls)'
  spec.homepage      = 'https://github.com/SidOfc/TwentyFortyEight'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = ['2048']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake',    '~> 13'
  spec.add_development_dependency 'rspec',   '~> 3.0'

  spec.add_runtime_dependency 'curses'
  spec.add_runtime_dependency 'json'
end
