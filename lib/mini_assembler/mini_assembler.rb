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

      @cpu = :wdc65816 # :spc700
      @mem_map = :lorom # :hirom

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

    def assemble_file(filename, outfile = 'out.smc')
      return 0 unless File.file?(filename)

      res = read(filename)
      write(outfile)

      return res
    end

    def read(filename, start_addr = nil)
      return 0 unless File.file?(filename)

      @label_registry = {}
      @address_registry = {}

      current_addr = start_addr || @current_addr
      current_bank_no = @current_bank_no
      instructions = []
      raw_bytes = []
      incbin_files = []

      cpu = @cpu

      2.times do |i|
        @current_addr = current_addr
        @current_bank_no = current_bank_no

        instructions = []
        File.open(filename).each_with_index do |raw_line, line_no|
          line = raw_line.split(';').first.strip.chomp
          next if line.empty?

          if line == '.spc700'
            @cpu = :spc700
            next
          elsif line == '.65816'
            @cpu = :wdc65816
            next
          elsif line == '.lorom'
            @mem_map = :lorom
            next
          elsif line == '.hirom'
            @mem_map = :hirom
            next
          end

          if matches = Definitions::READ_BYTE_SEQUENCE_REGEX.match(line)
            raw_addr = matches[1]
            if raw_addr.start_with?('%')
              addr = parse_address(line, true)
            else
              addr = full_address(matches[1].to_i(16))
            end
            bytes = matches[2].delete(' ').scan(/.{1,2}/).map { |b| hex(b.to_i(16)) }

            if i == 1
              raw_bytes << [addr, bytes]
            end

            if contains_label?(raw_addr)
              inc_addr(@current_addr, bytes.size)
            end
            next
          elsif matches = Definitions::READ_INCBIN_REGEX.match(line)
            raw_addr = matches[1]
            if raw_addr.start_with?('%')
              addr = parse_address(line, true)
            else
              addr = full_address(matches[1].to_i(16))
            end
            target_filename = matches[2].strip.chomp
            if i == 1
              incbin_files << [addr, target_filename]
            end

            if contains_label?(raw_addr)
              inc_addr(@current_addr, File.size(target_filename))
            end
            next
          elsif matches = Definitions::READ_BANK_SWITCH.match(line)
            new_bank_no = matches[1].to_i(16)
            max_bank_no = @mem_map == :hirom ? 0x3f : 0x7f
            return "Error at line #{line_no + 1}" if new_bank_no > max_bank_no
            @current_bank_no = new_bank_no
            @current_addr = 0

            next
          elsif matches = Definitions::READ_ADDR_SWITCH.match(line)
            new_addr = matches[1].to_i(16)
            return "Error at line #{line_no + 1}" if new_addr > 0xffff
            @current_addr = new_addr

            next
          end

          instruction, length, address = parse_instruction(line, register_label=(i == 0), resolve_label=(i==1))
          return "Error at line #{line_no + 1}" unless instruction

          instructions << [instruction, length, full_address(address)]
          bank_wrap = inc_addr(address, length)
          puts "Warning: bank wrap at line #{line_no + 1}" if bank_wrap && (i == 0)
        end
      end

      @cpu = cpu

      total_bytes_read = 0
      @current_bank_no = current_bank_no

      instructions.map do |instruction_arr|
        instruction, length, address = instruction_arr
        total_bytes_read += replace_memory_range(address, address + length - 1, instruction)
      end

      raw_bytes.each do |raw_byte|
        addr, bytes = raw_byte
        total_bytes_read += replace_memory_range(addr, addr + bytes.length - 1, bytes)
      end

      incbin_files.each do |file|
        addr, filename = file
        total_bytes_read += incbin(filename, addr)
      end

      dump_label_registry

      return "Read #{total_bytes_read} bytes"
    end

    def dump_label_registry
      dump = ['label,snes addr,rom addr']
      @label_registry.each do |k, v|
        next if k.start_with?('@')

        dump << "#{k},#{address_human(v[:mapped_addr], v[:mapped_bank])},#{hex(v[:rom_address], 6)}"
      end

      open('labels.csv', 'w') do |f|
        f << dump.join("\n")
      end
    end

    def detect_opcode_data_from_mnemonic(mnemonic, operand)
      SnesUtils.const_get(@cpu.capitalize)::Definitions::OPCODES_DATA.detect do |row|
        mode = row[:mode]
        regex = SnesUtils.const_get(@cpu.capitalize)::Definitions::MODES_REGEXES[mode]
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

    def full_address(address, bank_no = @current_bank_no)
      (bank_no << 16) | address
    end

    def inc_addr(address, length)
      @current_addr = address + length
      initial_bank_no = @current_bank_no

      while @current_addr > 0xffff
        @current_addr -= 0x10000
        @current_bank_no += 1
      end

      @current_bank_no != initial_bank_no
    end

    def address_human(addr=nil, cur_bank=@current_bank_no)
      address = full_address(addr || @current_addr, cur_bank)
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

      bytes.size
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
          start_addr = matches[2]&.to_i(16)
          filename = matches[3].strip.chomp

          return read(filename, start_addr)
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
          inc_addr(address, length)
          return disassemble_range(address, 1, length > 2).join
        end
      end
    end

    def mapped_address(address, absolute = false)
      return hex(address, 4) unless absolute

      if @mem_map == :lorom
        bank_offset = address / 0x8000
        mapped_addr = address - (bank_offset * 0x8000)
        mapped_addr += 0x8000 if mapped_addr < 0x8000
        mapped_bank = @current_bank_no * 2
        mapped_bank += bank_offset
        mapped_bank += 0x80 if mapped_bank < 0x7f

        { mapped_bank: mapped_bank, mapped_addr: mapped_addr, rom_address: full_address(address) }
      elsif @mem_map == :hirom
        mapped_bank = @current_bank_no + 0xc0 if @current_bank_no < 0x3f
        { mapped_bank: mapped_bank, mapped_addr: address, rom_address: full_address(address) }
      else
        { }
      end
    end

    def detect_label_type(address)
      if address.start_with?('@')
        :relative
      elsif address.start_with?('%')
        :absolute16
      elsif address.start_with?('&')
        :absolute24
      else
        nil
      end
    end

    def contains_label?(op)
      op.include?('@') | op.include?('%') | op.include?('&')
    end

    def parse_address(line, register_label = false)
      return @current_addr if line.index(':').nil?

      address = line.split(':').first.strip.chomp
      return -1 if address.to_i(16) > 0xffff
      return address.to_i(16) if detect_label_type(address).nil?

      label_type = detect_label_type(address)
      case label_type
      when :relative
        @label_registry[address] = mapped_address(@current_addr)
      when :absolute16
        @label_registry[address[1..-1]] = mapped_address(@current_addr, true)
      when :absolute24
        @label_registry[address[1..-1]] = mapped_address(@current_addr, true)
      else
        op
      end

      return @current_addr
    end

    def parse_instruction(line, register_label = false, resolve_label = false)
      current_address = parse_address(line, register_label)
      return if current_address < 0 || current_address > 0xffff
      instruction = line.split(':').last.split(' ')
      mnemonic = instruction[0].upcase
      raw_operand = instruction[1].to_s

      if register_label and contains_label?(raw_operand)
        raw_operand = raw_operand.split(',').map do |op|
          label_type = detect_label_type(op)
          case label_type
          when :relative
            mapped_address(@current_addr)
          when :absolute16
            dummy = mapped_address(@current_addr, true)
            dummy[:mapped_addr].to_s(16)
          when :absolute24
            dummy = mapped_address(@current_addr, true)
            full_address(dummy[:mapped_addr], dummy[:mapped_bank]).to_s(16)
          else
            op
          end
        end.join(',')
      end

      if resolve_label and contains_label?(raw_operand)
        raw_operand = raw_operand.split(',').map do |op|
          label_type = detect_label_type(op)
          case label_type
          when :relative
            @label_registry[op]
          when :absolute16
            @label_registry[op[1..-1]][:mapped_addr].to_s(16)
          when :absolute24
            full_address(@label_registry[op[1..-1]][:mapped_addr], @label_registry[op[1..-1]][:mapped_bank]).to_s(16)
          else
            op
          end
        end.join(',')
      end

      opcode_data = detect_opcode_data_from_mnemonic(mnemonic, raw_operand)

      return unless opcode_data

      opcode = hex(opcode_data[:opcode])
      mode = opcode_data[:mode]
      length = opcode_data[:length]

      operand_matches = SnesUtils.const_get(@cpu.capitalize)::Definitions::MODES_REGEXES[mode].match(raw_operand)

      if SnesUtils.const_get(@cpu.capitalize)::Definitions::DOUBLE_OPERAND_INSTRUCTIONS.include?(mode)
        if SnesUtils.const_get(@cpu.capitalize)::Definitions::BIT_INSTRUCTIONS.include?(mode)
          m = operand_matches[1].to_i(16)
          return if m > 0x1fff
          b = operand_matches[2].to_i(16)
          return if b > 7

          operand = m << 3 | 5
        else
          if SnesUtils.const_get(@cpu.capitalize)::Definitions::REL_INSTRUCTIONS.include?(mode)
            operand = [operand_matches[1], operand_matches[2]].map { |o| o.to_i(16) }
          else
            operand = "#{operand_matches[1]}#{operand_matches[2]}".to_i(16)
          end
        end
      else
        operand = operand_matches[1]&.to_i(16)
      end

      if operand
        if SnesUtils.const_get(@cpu.capitalize)::Definitions::REL_INSTRUCTIONS.include?(mode)
          if SnesUtils.const_get(@cpu.capitalize)::Definitions::DOUBLE_OPERAND_INSTRUCTIONS.include?(mode)
            relative_addr = operand[1] - current_address - length

            return if (relative_addr < -128 || relative_addr > 127)

            relative_addr = 0x100 + relative_addr if relative_addr < 0
            param_bytes = "#{hex(operand[0])}#{hex(relative_addr)}"
          else
            relative_addr = operand - current_address - length

            if @cpu == :wdc65816 && mode == :rell
              return if (relative_addr < -32768 || relative_addr > 32767)
            else
              return if (relative_addr < -128 || relative_addr > 127)
            end

            relative_addr = (2**(8*(length-1))) + relative_addr if relative_addr < 0
            param_bytes = hex(relative_addr, 2*(length-1)).scan(/.{2}/).reverse.join
          end
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
      absolute_addr += 0x10000 if absolute_addr.negative?

      [absolute_addr, relative_addr_s]
    end
  end
end
