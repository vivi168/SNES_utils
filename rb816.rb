def write(nbytes)
    data = (1..nbytes).map { |b| '00' }
    File.open('test.bin', 'w+b') do |file|
        file.write([data.join].pack('H*'))
    end
end

class MiniAssembler
    OPCODES = {
        adc: [
            '(dp,X)',
            'sr,S',
            'dp',
            '[dp]',
            '#const',
            'addr',
            'long',
            '(dp),Y',
            '(dp)',
            '(sr,S),Y',
            'dp,X',
            '[dp],Y',
            'addr,Y',
            'addr,X',
            'long,X'
        ],
        and: [
            '(dp,X)',
            'sr,S',
            'dp',
            '[dp]',
            '#const',
            'addr',
            'long',
            '(dp),Y',
            '(dp)',
            '(sr,S),Y',
            'dp,X',
            '[dp],Y',
            'addr,Y',
            'addr,X',
            'long,X'
        ],
        asl: [
            'dp',
            'A',
            'addr',
            'dp,X',
            'addr,X'
        ]
    }

    def initialize
        @normal_mode = true
        @lorom = true
        @memory = (1..0x8000).map { |b| rand(0..255).to_s(16).rjust(2, '0') }
        @program_counter = 0
    end

    def getline
        prompt = @normal_mode ? '*' : '!'
        print(prompt)
        gets.strip.chomp
    end

    def parse_line(line)
        if @normal_mode
            if line == '!'
                @normal_mode = false
                return
            elsif /^[0-9a-fA-F]+$/ =~ line
                return @memory[line.to_i(16)]
            elsif matches = /^([0-9a-fA-F]+)\.+([0-9a-fA-F]+)$/.match(line)
                start_addr = matches[1].to_i(16)
                end_addr = matches[2].to_i(16)
                end_addr = start_addr if end_addr < start_addr

                padding_count = start_addr % 8
                padding = (1..padding_count).map { |b| '  ' }
                arr = @memory[start_addr..end_addr].insert(8-padding_count, *padding).each_slice(8).to_a
                return arr.each_with_index.map do |row, idx|
                    if idx == 0
                        line_addr = start_addr
                    else
                        line_addr = start_addr - padding_count + idx * 8
                    end
                    ["#{line_addr.to_s(16).rjust(4, '0')}-", *row].join(' ')
                end.join("\n")
            end
        else
            if line == ''
                @normal_mode = true
                return
            end
        end
    end

    def parse_address(line)
        line.split(':').first.to_i
    end

    def parse_instruction(line)
    end

    def parse_mode(line, instruction)
    end
end

mini = MiniAssembler.new

while true
    line = mini.getline
    result = mini.parse_line(line)
    puts result if result
end
