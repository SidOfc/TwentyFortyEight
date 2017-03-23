require "spec_helper"

RSpec.describe TwentyFortyEight::Logger do
  it 'Can write a log' do
    dir  = File.dirname(__FILE__)
    path = File.expand_path File.join(dir, 'files')
    log  = TwentyFortyEight::Logger.new

    log << { some: :property, and: [:an_array], maybe: true, could_be: 1 }
    log << { some: :property, and: [:an_array], maybe: true, could_be: 2 }

    log.write! path: path, name: 'test'
    expect(File.exist?(File.join(path, 'test.log.json'))).to be true
    TwentyFortyEight::Logger.destroy! File.join(path, 'test.log.json')
  end

  it 'Can reopen a log' do
    path = File.expand_path File.join(File.dirname(__FILE__), 'files')
    full = File.join path, 'test_reopen.log.json'
    log  = TwentyFortyEight::Logger.new

    log << { some: :property, and: [:an_array], maybe: true, could_be: 1 }
    log << { some: :property, and: [:an_array], maybe: true, could_be: 2 }

    log.write! path: path, name: 'test_reopen'

    json = TwentyFortyEight::Logger.load!(full).entries.to_json

    expect(log.entries.to_json).to eq json
    TwentyFortyEight::Logger.destroy! full
  end

  it 'Can destroy a log' do
    path = File.expand_path File.join(File.dirname(__FILE__), 'files')
    full = File.join path, 'test_reopen.log.json'
    log  = TwentyFortyEight::Logger.new
    t    = TwentyFortyEight::Logger::FileNotFound

    log << { some: :property, and: [:an_array], maybe: true, could_be: 1 }
    log << { some: :property, and: [:an_array], maybe: true, could_be: 2 }

    log.write! path: path, name: 'test_reopen'

    expect(TwentyFortyEight::Logger.destroy!(full)).to be_truthy
    expect { TwentyFortyEight::Logger.destroy! 'somebs.file' }.to raise_error t
  end
end
