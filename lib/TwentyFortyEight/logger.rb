# frozen_string_literal: true

module TwentyFortyEight
  # Logger
  class Logger
    attr_reader :entries

    def initialize(entries = [])
      @entries = entries
    end

    def <<(info_hsh)
      entries << { time: (Time.now.to_f * 1000).to_i, info: info_hsh }
    end

    def write!(options = {})
      name   = (options[:name] || "2048-#{Time.now.to_i}") + '.log.json'
      path   = options[:path] || options[:dir] || Dir.pwd
      path   = File.expand_path('./' + path) unless path.start_with? '/'

      return unless Dir.exist?(path)
      File.open(File.join(path, name), 'w') { |f| f.write @entries.to_json }
    end

    def self.load!(path)
      full_path = File.expand_path path
      return unless File.exist? full_path
      new JSON.parse(File.read(full_path), symbolize_names: true)
    end

    def self.destroy!(path)
      full_path = File.expand_path path
      File.delete full_path if File.exist? full_path
    end
  end
end
