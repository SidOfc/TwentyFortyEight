# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'TwentyFortyEight/version'

Gem::Specification.new do |spec|
  spec.name          = 'TwentyFortyEight'
  spec.version       = TwentyFortyEight::VERSION
  spec.authors       = ['Sidney Liebrand']
  spec.email         = ['sidneyliebrand@gmail.com']

  spec.summary       = %(A 2048 game for terminals)
  spec.description   = 'Play a game of 2048 in the terminal, colorized using ' \
                       'Ruby curses. (See --help for options / controls)'
  spec.homepage      = 'https://sidofc.github.io/projects/2048'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = ['2048']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'coveralls'

  spec.add_runtime_dependency 'curses'
  spec.add_runtime_dependency 'json'
end
