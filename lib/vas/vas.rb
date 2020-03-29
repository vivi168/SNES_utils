module SnesUtils
  class Vas
    WDC65816 = :wdc65816
    SPC700 = :spc700

    DIRECTIVE = [
      '.65816', '.spc700', '.org', '.base', '.db', '.define', '.incbin', '.incsrc'
    ]

    def initialize(filename)
      raise unless File.file?(filename)

      @filename = filename
      @label_registry = []
      @memory = []
    end

    def assemble
      2.times do |pass|
        @program_counter = 0
        @origin = 0
        @base = 0
        @cpu = WDC65816

        assemble_file(pass)
      end

      write
    end

    def assemble_file(pass)
      File.open(@filename).each_with_index do |raw_line, line_no|
        @line = raw_line.split(';').first.strip.chomp
        next if @line.empty?

        if @line.start_with?(*DIRECTIVE)
          process_directive
          next
        end

        if @line.include?(':')
          arr = @line.split(':')
          label = arr[0].strip.chomp
          unless /^@\w+$/ =~ label
            puts "Error: invalid label"
            raise
          end
          @label_registry << [label[1..-1], @program_counter + @origin] if pass == 0
          next unless arr[1]
          instruction = arr[1].strip.chomp
        else
          instruction = @line
        end

        next if instruction.empty?

        begin
          bytes = LineAssembler.new(instruction, options).assemble
        rescue
          puts "Error at line #{line_no + 1}"
          raise
        end

        insert(bytes) if pass == 1
        @program_counter += bytes.size
      end
    end

    def insert(bytes)
      insert_at = @program_counter + @base
      @memory[insert_at..bytes.size] = bytes
    end

    def write(filename = 'out.smc')
      File.open(filename, 'w+b') do |file|
        file.write([@memory.map { |i| Vas::hex(i) }.join].pack('H*'))
      end

      filename
    end

    def self.hex(num, rjust_len = 2)
      (num || 0).to_s(16).rjust(rjust_len, '0').upcase
    end

    def options
      {
        program_counter: @program_counter,
        origin: @origin,
        cpu: @cpu,
        label_registry: @label_registry
      }
    end

    def process_directive
      directive = @line.split(' ')

      case directive[0]
      when '.65816'
        @cpu = WDC65816
      when '.spc700'
        @cpu = SPC700
      when '.org'
        update_origin(directive[1].to_i(16))
      when '.base'
        @base = directive[1].to_i(16)
      end
    end

    def update_origin(param)
      @origin = param

      update_base_from_origin
    end

    def update_base_from_origin
      # TODO: automatically update base
      # lorom/hirom scheme
      # spc700 scheme
    end
  end

  class LineAssembler
    def initialize(raw_line, **options)
      @line = raw_line.split(';').first.strip.chomp
      @current_address = (options[:program_counter] + options[:origin])
      @cpu = options[:cpu]
      @label_registry = options[:label_registry]
    end

    def assemble
      instruction = @line.split(' ')
      mnemonic = instruction[0].upcase
      raw_operand = instruction[1].to_s

      raw_operand = replace_label(raw_operand) if contains_label?(raw_operand)

      opcode_data = detect_opcode(mnemonic, raw_operand)
      raise unless opcode_data

      opcode = opcode_data[:opcode]
      @mode = opcode_data[:mode]
      @length = opcode_data[:length]

      operand_data = detect_operand(raw_operand)

      operand = process_operand(operand_data)

      return [opcode, *operand]
    end

    def contains_label?(operand)
      operand.include?('@') || operand.include?('!')
    end

    def replace_label(operand)
      raise unless matches = /(@|!)(\w+)/.match(operand)

      mode = matches[1]
      label = matches[2]

      label_data = @label_registry.detect { |l| l[0] == label }

      value = label_data ? label_data[1] : @current_address

      if mode == '@'
        value = value & 0x00ffff
        new_value = Vas::hex(value, 4)
      else
        value = value | (((@current_address >> 16) & 0xff) << 16)
        new_value = Vas::hex(value, 6)
      end

      operand.gsub(/(@|!)\w+/, new_value)
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
        operand = operand_data[1]&.to_i(16)
        rel_instruction? ? process_rel_operand(operand) : little_endian(operand, @length - 1)
      end
    end

    def process_double_operand_instruction(operand_data)
      if bit_instruction?
        process_bit_operand(operand_data)
      else
        operands = [operand_data[1], operand_data[2]].map { |o| o.to_i(16) }
        operand_2 = rel_instruction? ? process_rel_operand(operands[1]) : operands[1]

        rel_instruction? ? [operands[0], operand_2] : [operand_2, operands[0]]
      end
    end

    def process_bit_operand(operand_data)
      m = operand_data[1].to_i(16)
      raise if m > 0x1fff

      b = operand_data[2].to_i(16)
      raise if b > 7

      little_endian(m << 3 | b, 2)
    end

    def process_rel_operand(operand)
      relative_addr = operand - (@current_address & 0x00ffff) - @length

      if @cpu == Vas::WDC65816 && @mode == :rell
        raise if relative_addr < -32_768 || relative_addr > 32_767

        relative_addr += 0x10000 if relative_addr < 0
        little_endian(relative_addr, 2)
      else
        raise if relative_addr < -128 || relative_addr > 127

        relative_addr += 0x100 if relative_addr < 0
        relative_addr
      end

    end

    def little_endian(operand, length)
      if length > 2
        [((operand >> 0) & 0xff), ((operand >> 8) & 0xff), ((operand >> 16) & 0xff)]
      elsif length > 1
        [((operand >> 0) & 0xff), ((operand >> 8) & 0xff)]
      else
        operand
      end
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
