module SnesUtils
  class Vas
    def initialize(filename)
      raise unless File.file?(filename)

      @filename = filename
      @program_counter = 0x5ff
      @origin = 0
    end

    def assemble
      File.open(@filename).each_with_index do |raw_line, line_no|
        bytes = LineParser.new(raw_line, @program_counter).parse
        @program_counter += bytes.size
      end
    end
  end

  class LineParser
    INSTRUCTIONS = [
      '.org', '.db', '.define', '.incbin', '.incsrc'
    ]
    WDC65816 = :wdc65816
    SPC700 = :spc700

    def initialize(raw_line, program_counter)
      @line = raw_line.split(';').first.strip.chomp
      # @cpu = WDC65816
      @cpu = SPC700
      @program_counter = program_counter

      puts @line
    end

    def parse
      # TODO process custom instruction, labels
      raise if @line.start_with?('.')

      instruction = @line.split(':').last.split(' ')
      mnemonic = instruction[0].upcase
      raw_operand = instruction[1].to_s

      opcode_data = detect_opcode(mnemonic, raw_operand)
      raise unless opcode_data

      opcode = opcode_data[:opcode]
      @mode = opcode_data[:mode]
      @length = opcode_data[:length]

      operand_data = detect_operand(raw_operand)

      operand = process_operand(operand_data)

      return [opcode, *operand]
    end

    def detect_opcode(mnemonic, operand)
      SnesUtils.const_get(@cpu.capitalize)::Definitions::OPCODES_DATA.detect do |row|
        mode = row[:mode]
        regex = SnesUtils.const_get(@cpu.capitalize)::Definitions::MODES_REGEXES[mode]
        row[:mnemonic] == mnemonic && regex =~ operand
      end
    end

    def detect_operand(raw_operand)
      SnesUtils.const_get(@cpu.capitalize)::Definitions::MODES_REGEXES[@mode].match(raw_operand)
    end

    def process_operand(operand_data)
      if double_operand_instruction?
        process_double_operand_instruction(operand_data)
      else
        operand = [operand_data[1]&.to_i(16)]
        rel_instruction? ? process_rel_operand(operand) : operand
      end
    end

    def process_double_operand_instruction(operand_data)
      if bit_instruction?
        m = operand_data[1].to_i(16)
        raise if m > 0x1fff

        b = operand_data[2].to_i(16)
        raise if b > 7

        operand = m << 3 | b
      else
        operands = [operand_data[1], operand_data[2]].map { |o| o.to_i(16) }
        second_operand = rel_instruction? ? process_rel_operand(operands[1]) : operands[1]

        [operands[0], second_operand]
      end
    end

    def process_rel_operand(operand)
      relative_addr = operand - @program_counter - @length

      if @cpu == WDC65816 && mode == :rell
        raise if relative_addr < -32_768 || relative_addr > 32_767

        relative_addr += 0x10000 if relative_addr < 0
      else
        raise if relative_addr < -128 || relative_addr > 127

        relative_addr += 0x100 if relative_addr < 0
      end

      relative_addr
    end

    def double_operand_instruction?
      SnesUtils.const_get(@cpu.capitalize)::Definitions::DOUBLE_OPERAND_INSTRUCTIONS.include?(@mode)
    end

    def bit_instruction?
      SnesUtils.const_get(@cpu.capitalize)::Definitions::BIT_INSTRUCTIONS.include?(@mode)
    end

    def rel_instruction?
      SnesUtils.const_get(@cpu.capitalize)::Definitions::REL_INSTRUCTIONS.include?(@mode)
    end
  end
end
