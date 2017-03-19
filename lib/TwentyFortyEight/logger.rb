# frozen_string_literal: true
module TwentyFortyEight
  # Logger
  class Logger
    attr_reader :entries

    def initialize
      @entries = []
    end

    def <<(info_hsh)
      entries << { time: (Time.now.to_f * 1000).to_i, info: info_hsh }
    end

    def write!(options = {})
      name = (options[:name] || "2048-#{Time.now.to_i}") + '.log.json'
      path = File.expand_path(options[:path]) if options[:path]
      path = File.join(Dir.pwd, name) unless options[:dir]
      path = (File.join Dir.pwd, options[:dir], name) if options[:dir]

      File.open(path, 'w') { |f| f.write @entries.to_json }
    end
  end
end
