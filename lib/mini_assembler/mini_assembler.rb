module SnesUtils
  Readline.completion_proc = proc do |input|
    Wdc65816::Definitions::OPCODES_DATA.map { |row| row[:mnemonic] }
                               .select { |mnemonic| mnemonic.upcase.start_with?(input.upcase) }
  end

  class MiniAssembler
    def initialize(filename = nil)
      if filename && File.file?(filename)
        file = File.open(filename)
        @memory = file.each_byte.map { |b| hex(b) }
      else
        @memory = []
      end

      @cpu = :wdc65816

      @normal_mode = true

      @current_addr = 0
      @current_bank_no = 0
      @accumulator_flag = 1
      @index_flag = 1

      @next_addr_to_list = 0
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

      filename
    end

    def incbin(filename, addr)
      return 0 unless File.file?(filename)

      file = File.open(filename)
      bytes = file.each_byte.map { |b| hex(b) }

      replace_memory_range(addr, addr + bytes.size - 1, bytes)

      bytes.size
    end

    def read(filename)
      return 0 unless File.file?(filename)

      file = File.open(filename)

      instructions = []

      file.each_with_index do |raw_line, line_no|
        line = raw_line.split(';').first.strip.chomp
        next if line.empty?

        instruction, length, address = parse_instruction(line)
        return "Error at line #{line_no + 1}" unless instruction

        instructions << [instruction, length, address]
        @current_addr = address + length
      end

      disassembled_instructions = []
      instructions.map do |instruction_arr|
        instruction, length, address = instruction_arr
        replace_memory_range(address, address+length-1, instruction)
        disassembled_instructions << disassemble_range(address, 1, length > 2).join
      end

      return disassembled_instructions
    end

    def detect_opcode_data_from_mnemonic(mnemonic, operand)
      Wdc65816::Definitions::OPCODES_DATA.detect do |row|
        mode = row[:mode]
        regex = Wdc65816::Definitions::MODES_REGEXES[mode]
        row[:mnemonic] == mnemonic && regex =~ operand
      end
    end

    def detect_opcode_data_from_opcode(opcode, force_length)
      SnesUtils.const_get(@cpu.capitalize)::Definitions::OPCODES_DATA.detect do |row|
        if @cpu == :spc700
          row[:opcode] == opcode
        else
          if row[:m]
            accumulator_flag = force_length ? 0 : @accumulator_flag
            row[:opcode] == opcode && row[:m] == accumulator_flag
          elsif row[:x]
            index_flag = force_length ? 0 : @index_flag
            row[:opcode] == opcode && row[:x] == index_flag
          else
            row[:opcode] == opcode
          end
        end
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

      return [] if start_full_addr > end_full_addr || start_full_addr >= @memory.length

      @memory[start_full_addr..end_full_addr]
    end

    def replace_memory_range(start_addr, end_addr, bytes)
      start_full_addr = full_address(start_addr)
      end_full_addr = full_address(end_addr)

      @memory[start_full_addr..end_full_addr] = bytes

      true
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
        elsif line == '.spc700'
          @cpu = :spc700
          return 'spc700'
        elsif line == '.65816'
          @cpu = :wdc65816
          return '65816'
        elsif matches = Definitions::WRITE_REGEX.match(line)
          filename = matches[1].strip.chomp
          out_filename = write(filename)
          return "Written #{@memory.size} bytes to file #{out_filename}"
        elsif matches = Definitions::READ_REGEX.match(line)
          filename = matches[1].strip.chomp
          return read(filename)
        elsif matches = Definitions::INCBIN_REGEX.match(line)
          start_addr = matches[1].to_i(16)
          filename = matches[2].strip.chomp
          nb_bytes = incbin(filename, start_addr)

          return "Inserted #{nb_bytes} bytes at #{address_human(start_addr)}"
        elsif Definitions::BYTE_LOC_REGEX =~ line
          return memory_loc(line.to_i(16))
        elsif matches = Definitions::BYTE_RANGE_REGEX.match(line)
          start_addr = matches[1].to_i(16)
          end_addr = matches[2].to_i(16)

          padding_count = start_addr % 8
          padding = (1..padding_count).map { |b| '  ' }
          arr = memory_range(start_addr, end_addr)
          return if arr.empty?

          padded_arr = arr.insert(8-padding_count, *padding).each_slice(8).to_a
          return padded_arr.each_with_index.map do |row, idx|
            if idx == 0
              line_addr = start_addr
            else
              line_addr = start_addr - padding_count + idx * 8
            end
            ["#{address_human(line_addr)}-", *row].join(' ')
          end.join("\n")
        elsif matches = Definitions::BYTE_SEQUENCE_REGEX.match(line)
          addr = matches[1].to_i(16)
          bytes = matches[2].delete(' ').scan(/.{1,2}/).map { |b| hex(b.to_i(16)) }
          replace_memory_range(addr, addr + bytes.length - 1, bytes)
          return
        elsif matches = Definitions::DISASSEMBLE_REGEX.match(line)
          start = matches[1].empty? ? @next_addr_to_list : matches[1].to_i(16)
          return disassemble_range(start, 20).join("\n")
        elsif matches = Definitions::SWITCH_BANK_REGEX.match(line)
          target_bank_no = matches[1].to_i(16)
          @current_bank_no = target_bank_no
          @current_addr = @current_bank_no << 16
          @next_addr_to_list = 0
          return
        elsif matches = Definitions::FLIP_MX_REG_REGEX.match(line)
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

      opcode_data = detect_opcode_data_from_mnemonic(mnemonic, raw_operand)

      return unless opcode_data

      opcode = hex(opcode_data[:opcode])
      mode = opcode_data[:mode]
      length = opcode_data[:length]

      operand_matches = Wdc65816::Definitions::MODES_REGEXES[mode].match(raw_operand)
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

    def auto_update_flags(opcode, operand)
      if 0xc2 == opcode
        @index_flag = 0 if (operand & 0x10) == 0x10
        @accumulator_flag = 0 if (operand & 0x20) == 0x20
      elsif 0xe2 == opcode
        @index_flag = 1 if (operand & 0x10) == 0x10
        @accumulator_flag = 1 if (operand & 0x20) == 0x20
      end
    end

    def disassemble_range(start, count, force_length = false)
      next_idx = start
      instructions = []
      count.times do
        byte = memory_loc(next_idx)
        break unless byte
        opcode = byte.to_i(16)

        opcode_data = detect_opcode_data_from_opcode(opcode, force_length)

        mnemonic = opcode_data[:mnemonic]
        mode = opcode_data[:mode]
        length = opcode_data[:length]

        format = SnesUtils.const_get(@cpu.capitalize)::Definitions::MODES_FORMATS[mode]

        operand = memory_range(next_idx+1, next_idx+length-1).reverse.join.to_i(16)

        hex_encoded_instruction = memory_range(next_idx, next_idx+length-1)
        prefix = ["#{address_human(next_idx)}:", *hex_encoded_instruction].join(' ')

        auto_update_flags(opcode, operand) if @cpu == :wdc65816

        if SnesUtils.const_get(@cpu.capitalize)::Definitions::DOUBLE_OPERAND_INSTRUCTIONS.include?(mode)
          if SnesUtils.const_get(@cpu.capitalize)::Definitions::BIT_INSTRUCTIONS.include?(mode)
            m = operand >> 3
            b = operand & 0b111
            operand = [m, b]
          else
            operand = hex(operand, 4).scan(/.{2}/).map { |op| op.to_i(16) }
            if @cpu == :spc700 && SnesUtils.const_get(@cpu.capitalize)::Definitions::REL_INSTRUCTIONS.include?(mode)
              r = operand.first
              r_operand = relative_operand(r, next_idx + length)

              operand = [operand.last, *r_operand]
            end
          end
        elsif SnesUtils.const_get(@cpu.capitalize)::Definitions::SINGLE_OPERAND_INSTRUCTIONS.include?(mode)
          if SnesUtils.const_get(@cpu.capitalize)::Definitions::REL_INSTRUCTIONS.include?(mode)
            if @cpu == :wdc65816 && SnesUtils.const_get(@cpu.capitalize)::Definitions::REL_INSTRUCTIONS.include?(mode)
              limit = mode == :rel ? 0x7f : 0x7fff
              offset = mode == :rel ? 0x100 : 0x10000
              rjust_len = mode == :rel ? 2 : 4
              operand = relative_operand(operand, next_idx + length, limit, offset, rjust_len)
            else
              operand = relative_operand(operand, next_idx + length)
            end
          end
        end

        instructions << "#{prefix.ljust(30)} #{format % [mnemonic, *operand]}"
        next_idx += length
      end

      @next_addr_to_list = next_idx
      return instructions
    end

    def relative_operand(operand, next_idx, limit = 0x7f, offset = 0x100, rjust_len = 2)
      relative_addr = operand > limit ? operand - offset : operand
      relative_addr_s = "#{relative_addr.positive? ? '+' : '-'}#{hex(relative_addr.abs, rjust_len)}"
      absolute_addr = next_idx + relative_addr
      # TODO: check that offset is correct with negatives
      absolute_addr += offset if absolute_addr.negative?

      [absolute_addr, relative_addr_s]
    end
  end
end
