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
      name = (options[:name] || "2048-#{Time.now.to_i}") + '.log.json'
      path = File.join File.expand_path(options[:path]), name if options[:path]
      path = File.join(Dir.pwd, name) unless options[:dir] || options[:path]
      path = (File.join Dir.pwd, options[:dir], name) if options[:dir]

      File.open(path, 'w') { |f| f.write @entries.to_json }
    end

    def self.load!(path)
      full_path = File.expand_path path
      check_file_existence! full_path

      new JSON.parse(File.read(full_path), symbolize_names: true)
    end

    def self.destroy!(path)
      full_path = File.expand_path path
      check_file_existence! full_path
      File.delete full_path
    end

    def self.check_file_existence!(path)
      raise FileNotFound, 'Log does not exist' unless File.exist? path
    end

    class FileNotFound < StandardError; end
  end
end
