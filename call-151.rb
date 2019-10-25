require 'optparse'

require_relative 'mini_assembler/mini_assembler'

options = {}
OptionParser.new do |opts|
  opts.on('-f', '--file FILENAME', 'ROM file') { |o| options[:filename] = o }
end.parse!

MiniAssembler.new(options[:filename]).run

