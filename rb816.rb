require_relative 'mini_assembler/mini_assembler'

mini = MiniAssembler.new('demo.smc')

while true
  line = mini.getline
  result = mini.parse_line(line)
  puts result if result
end
