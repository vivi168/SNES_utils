require 'optparse'

require_relative 'mini_assembler/mini_assembler'

options = {}
OptionParser.new do |opts|
  opts.on('-f', '--file FILENAME', 'ROM file') { |o| options[:filename] = o }
end.parse!

mini = MiniAssembler.new(options[:filename])

while true
  line = mini.getline
  result = mini.parse_line(line)
  puts result if result
end
