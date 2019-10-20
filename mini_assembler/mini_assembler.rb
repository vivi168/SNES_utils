require 'csv'
require 'readline'
require 'byebug'

require_relative './regexes'

Readline.completion_proc = proc do |input|
  MiniAssembler.opcodes.map { |row| row['mnemonic'] }.select { |mnemonic| mnemonic.upcase.start_with?(input.upcase) }
end

class MiniAssembler
  include Regexes

  def initialize(file = nil)
    if file && File.file?(file)
      @file = File.open(file)
      @memory = @file.each_byte.map { |b| hex(b) }
    else
      @memory = []
    end

    @normal_mode = true

    @current_addr = 0
    @current_bank_no = 0
    @accumulator_flag = 1
    @index_flag = 1
  end

  def run
    while line = getline
      result = parse_line(line.strip.chomp)
      puts result if result
    end

    puts
  end

  def hex(num, rjust_len = 2)
    num.to_s(16).rjust(rjust_len, '0').upcase
  end

  def write(filename = 'out.smc')
    filename = filename.empty? ? 'out.smc' : filename

    File.open(filename, 'w+b') do |file|
      file.write([@memory.map { |i| i ? i : '00' }.join].pack('H*'))
    end
  end

  def incbin(filepath, addr)
    file = File.open(filepath)
    bytes = file.each_byte.map { |b| hex(b) }

    replace_memory_range(addr, addr + bytes.size - 1, bytes)
  end

  def self.opcodes
    @opcodes ||= CSV.parse(File.read(File.join(File.dirname(__FILE__), "/opcodes.csv")), headers: true, converters: %i[numeric])
  end

  def detect_opcode_data(mnemonic, operand)
    MiniAssembler.opcodes.detect do |row|
      mode = row['mode'].to_sym
      regex = MiniAssembler::MODES_REGEXES[mode]
      row['mnemonic'] == mnemonic && regex =~ operand
    end
  end

  def full_address(address)
    (@current_bank_no << 16) | address
  end

  def address_human(addr=nil)
    address = full_address(addr || @current_addr)
    bank = address >> 16
    addr = (((address>>8)&0xFF) << 8) | (address&0xFF)
    "#{hex(bank)}/#{hex(addr, 4)}"
  end

  def memory_loc(address)
    @memory[full_address(address)]
  end

  def memory_range(start_addr, end_addr)
    start_full_addr = full_address(start_addr)
    end_full_addr = full_address(end_addr)

    @memory[start_full_addr..end_full_addr]
  end

  def replace_memory_range(start_addr, end_addr, bytes)
    start_full_addr = full_address(start_addr)
    end_full_addr = full_address(end_addr)

    @memory[start_full_addr..end_full_addr] = bytes
  end

  def getline
    prompt = @normal_mode ? "(#{@accumulator_flag}=m #{@index_flag}=x)*" : "(#{address_human})!"
    Readline.readline(prompt, true)
  end

  def parse_line(line)
    if @normal_mode
      if line == '!'
        @normal_mode = false
        return
      elsif matches = MiniAssembler::WRITE.match(line)
        filename = matches[1].strip.chomp
        write(filename)
        return 'written'
      elsif matches = MiniAssembler::INCBIN.match(line)
        start_addr = matches[1].to_i(16)
        filepath = matches[2].strip.chomp
        incbin(filepath, start_addr)
        return 'incbin'
      elsif MiniAssembler::BYTE_LOC =~ line
        return memory_loc(line.to_i(16))
      elsif matches = MiniAssembler::BYTE_RANGE.match(line)
        start_addr = matches[1].to_i(16)
        end_addr = matches[2].to_i(16)
        end_addr = start_addr if end_addr < start_addr

        # TODO check address is in current bank

        padding_count = start_addr % 8
        padding = (1..padding_count).map { |b| '  ' }
        arr = memory_range(start_addr, end_addr).insert(8-padding_count, *padding).each_slice(8).to_a
        return arr.each_with_index.map do |row, idx|
          if idx == 0
            line_addr = start_addr
          else
            line_addr = start_addr - padding_count + idx * 8
          end
          ["#{address_human(line_addr)}-", *row].join(' ')
        end.join("\n")
      elsif matches = MiniAssembler::BYTE_SEQUENCE.match(line)
        addr = matches[1].to_i(16)
        bytes = matches[2].delete(' ').scan(/.{1,2}/).map { |b| hex(b.to_i(16)) }
        replace_memory_range(addr, addr + bytes.length - 1, bytes)
        return
      elsif matches = MiniAssembler::DISASSEMBLE.match(line)
        start = matches[1].to_i(16)
        return disassemble_range(start, 20).join("\n")
      elsif matches = MiniAssembler::SWITCH_BANK.match(line)
        target_bank_no = matches[1].to_i(16)
        @current_bank_no = target_bank_no
        @current_addr = @current_bank_no << 16
        return hex(@current_bank_no)
      elsif matches = MiniAssembler::FLIP_MX_REG.match(line)
        val = matches[1]
        reg = matches[2]

        if reg.downcase == 'm'
          @accumulator_flag = val.to_i
        elsif reg.downcase == 'x'
          @index_flag = val.to_i
        end

        return
      end
    else
      if line == ''
        @normal_mode = true
        return
      else
        instruction, length, address = parse_instruction(line)
        return 'error' unless instruction

        replace_memory_range(address, address+length-1, instruction)
        @current_addr = address + length
        return disassemble_range(address, 1, length > 2).join
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
    raw_operand = instruction[1].to_s

    opcode_data = detect_opcode_data(mnemonic, raw_operand)

    return unless opcode_data

    opcode = hex(opcode_data['opcode'])
    mode = opcode_data['mode'].to_sym
    length = opcode_data['length']

    operand_matches = MiniAssembler::MODES_REGEXES[mode].match(raw_operand)
    if mode == :bm
      operand = "#{operand_matches[1]}#{operand_matches[2]}".to_i(16)
    else
      operand = operand_matches[1]&.to_i(16)
    end

    if operand
      if %i[rel rell].include? mode
        relative_addr = operand - current_address - length
        return if mode == :rel && (relative_addr < -128 || relative_addr > 127)
        return if mode == :rell && (relative_addr < -32768 || relative_addr > 32767)

        relative_addr = (2**(8*(length-1))) + relative_addr if relative_addr < 0

        param_bytes = hex(relative_addr, 2*(length-1)).scan(/.{2}/).reverse.join
      else
        param_bytes = hex(operand, 2*(length-1)).scan(/.{2}/).reverse.join
      end
    end

    encoded_result = "#{opcode}#{param_bytes}"

    return [encoded_result.scan(/.{2}/), length, current_address]
  end

  def disassemble_range(start, count, force_length = false)
    next_idx = start
    instructions = []
    count.times do
      byte = memory_loc(next_idx)
      break unless byte
      opcode = byte.to_i(16)

      opcode_data = MiniAssembler.opcodes.detect do |row|
        if row['m']
          accumulator_flag = force_length ? 0 : @accumulator_flag
          row['opcode'] == opcode && row['m'] == accumulator_flag
        elsif row['x']
          index_flag = force_length ? 0 : @index_flag
          row['opcode'] == opcode && row['x'] == index_flag
        else
          row['opcode'] == opcode
        end
      end

      mnemonic = opcode_data['mnemonic']
      mode = opcode_data['mode'].to_sym
      length = opcode_data['length']

      format = MiniAssembler::MODES_FORMATS[mode]

      operand = memory_range(next_idx+1, next_idx+length-1).reverse.join.to_i(16)

      hex_encoded_instruction = memory_range(next_idx, next_idx+length-1)
      prefix = ["#{address_human(next_idx)}:", *hex_encoded_instruction].join(' ')

      if mode == :bm
        operand = operand.to_s(16).scan(/.{2}/).map { |op| op.to_i(16) }
      elsif %i[rel rell].include? mode
        limit = mode == :rel ? 0x7f : 0x7fff
        offset = mode == :rel ? 0x100 : 0x10000
        rjust_len = mode == :rel ? 2 : 4
        relative_addr = operand > limit ? operand - offset : operand
        relative_addr_s = "#{relative_addr.positive? ? '+' : '-'}#{hex(relative_addr.abs, rjust_len)}"
        absolute_addr = next_idx + length + relative_addr
        absolute_addr += 0x10000 if absolute_addr.negative?
        operand = [absolute_addr, relative_addr_s]
      end

      instructions << "#{prefix.ljust(30)} #{format % [mnemonic, *operand]}"
      next_idx += length
    end

    return instructions
  end
end
