require 'yaml'
require 'readline'
require 'byebug'

require_relative './regexes'
require_relative './opcodes'

def write(nbytes)
  data = (1..nbytes).map { |b| '00' }
  File.open('test.bin', 'w+b') do |file|
    file.write([data.join].pack('H*'))
  end
end

class MiniAssembler
  include Regexes
  include Opcodes

  def initialize
    @normal_mode = true
    @bank_no = 0x100
    @bank_size = 0x10000
    @memory = (0..@bank_no-1).map { |bank| (0..@bank_size-1).map { |b| rand(0..255).to_s(16).rjust(2, '0') } }
    @current_addr = 0
    @current_bank_no = 0
    @accumulator = 1
    @index = 1
  end

  def opcodes
    # write spec to check integrity of this file
    @opcodes = YAML.load_file File.join(File.dirname(__FILE__), "/opcodes/opcodes.yml")
  end

  def current_bank
    @memory[@current_bank_no]
  end

  def getline
    prompt = @normal_mode ? "(#{@accumulator}=m #{@index}=x)*" : "!"
    Readline.readline(prompt, true).strip.chomp
  end

  def parse_line(line)
    if @normal_mode
      if line == '!'
        @normal_mode = false
        return
      elsif MiniAssembler::BYTE_LOC =~ line
        return current_bank[line.to_i(16)]
      elsif matches = MiniAssembler::BYTE_RANGE.match(line)
        start_addr = matches[1].to_i(16)
        end_addr = matches[2].to_i(16)
        end_addr = start_addr if end_addr < start_addr

        # TODO check address is in current bank

        padding_count = start_addr % 8
        padding = (1..padding_count).map { |b| '  ' }
        arr = current_bank[start_addr..end_addr].insert(8-padding_count, *padding).each_slice(8).to_a
        return arr.each_with_index.map do |row, idx|
          if idx == 0
            line_addr = start_addr
          else
            line_addr = start_addr - padding_count + idx * 8
          end
          ["#{@current_bank_no.to_s(16).rjust(2, '0')}/#{line_addr.to_s(16).rjust(4, '0')}-", *row].join(' ')
        end.join("\n")
      elsif matches = MiniAssembler::BYTE_SEQUENCE.match(line)
        addr = matches[1].to_i(16)
        bytes = matches[2].delete(' ').scan(/.{1,2}/).map { |b| b.to_i(16).to_s(16).rjust(2, '0') }
        current_bank[addr..addr+bytes.length-1] = bytes
        return
      elsif matches = MiniAssembler::DISASSEMBLE.match(line)
        start = matches[1].to_i(16)
        return disassemble_range(start, 20).join("\n")
      elsif matches = MiniAssembler::SWITCH_BANK.match(line)
        # check if memory has enough bank.
        # lowrom bank size = 0x8000
        # hirom bank size =  0x10000
        @current_bank_no = matches[1].to_i(16)
      elsif matches = MiniAssembler::FLIP_MX_REG.match(line)
        val = matches[1]
        reg = matches[2]

        if reg.downcase == 'm'
          @accumulator = val.to_i
        elsif reg.downcase == 'x'
          @index = val.to_i
        end

        return
      end
    else
      if line == ''
        @normal_mode = true
        return
      else
        address = parse_address(line)
        instruction, length = parse_instruction(line)
        return 'error' unless instruction
        current_bank[address..address+length-1] = instruction
        @current_addr = address + length
        return disassemble_range(address, 1, length > 2)
      end
    end
  end

  def parse_address(line)
    return @current_addr if line.index(':').nil?
    line.split(':').first.to_i(16)
  end

  def parse_instruction(line)
    current_address = parse_address(line)
    instruction = line.split(':').last.split(' ')
    mnemonic = instruction[0].upcase
    param = instruction[1].to_s

    opcodes_list = opcodes[mnemonic.to_sym]
    return [nil, nil] unless opcodes_list&.any?

    mode = parse_mode(opcodes_list, param)

    return [nil, nil] unless mode&.any?
    opcode_info = opcodes_list[mode[0]]
    opcode = opcode_info[0]
    length = opcode_info[1].to_i

    if mode[1]
      mode_param = mode[1]
      if %i[rel rell].include? mode[0]
        relative_addr = mode_param - current_address - length
        relative_addr = (2**(8*(length-1))) + relative_addr if relative_addr < 0

        param_bytes = relative_addr.to_s(16).rjust(2*(length-1), '0').scan(/.{2}/).reverse.join
      else
        param_bytes = mode_param.to_s(16).rjust(2*(length-1), '0').scan(/.{2}/).reverse.join
      end
    end

    encoded_result = "#{opcode}#{param_bytes}"

    return [encoded_result.scan(/.{2}/), length]
  end

  def parse_mode(available_modes, param)
    available_modes.keys.map do |m|
      if matches = MiniAssembler::MODES_REGEXES[m].match(param)
        if matches.length > 1
          [m, matches[1].to_i(16)]
        else
          [m, nil]
        end
      end
    end.compact.first
  end

  def disassemble_range(start, count, force_length = false)
    next_idx = start
    instructions = []
    count.times do
      opcode = current_bank[next_idx].to_i(16)
      instruction_arr = MiniAssembler::OPCODES[opcode]
      length = instruction_arr[0].to_i # TODO change array data type to int
      formats = instruction_arr[1]
      if formats.is_a? Array
        offset = force_length ? 0 : @accumulator
        format = formats[offset] # TODO for LDX,LDY etc, it's actually @index register
        length -= offset
      else
        format = formats
      end

      if length > 1
      end

      param = current_bank[next_idx+1..next_idx+length-1].reverse.join.to_i(16)

      hex_codes = current_bank[next_idx..next_idx+length-1]
      prefix = ["#{@current_bank_no.to_s(16).rjust(2, '0')}/#{next_idx.to_s(16).rjust(4, '0')}:", *hex_codes].join(' ')

      instructions << "#{prefix.ljust(40)} #{format % param}".upcase
      next_idx += length
    end

    return instructions
  end
end
