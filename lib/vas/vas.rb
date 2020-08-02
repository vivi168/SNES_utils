module SnesUtils
  class Vas
    WDC65816 = :wdc65816
    SPC700 = :spc700

    DIRECTIVE = [
      '.65816', '.spc700', '.org', '.base', '.db', '.rb', '.incbin', '.incsrc'
    ]

    LABEL_OPERATORS = ['@', '!', '<', '>', '\^']

    def initialize(filename)
      raise "File not found: #{filename}" unless File.file?(filename)

      @filename = filename
      @file = []
      @label_registry = []
      @incbin_list = []
      @byte_sequence_list = []
      @memory = []
    end

    def assemble
      construct_file

      2.times do |pass|
        @program_counter = 0
        @origin = 0
        @base = 0
        @cpu = WDC65816

        assemble_file(pass)
      end

      write_label_registry
      insert_bytes
      incbin
      write
    end

    def construct_file(filename = @filename)
      File.open(filename).each do |raw_line|
        line = raw_line.split(';').first.strip.chomp
        next if line.empty?

        if line.start_with?('.include')
          directive = line.split(' ')
          inc_filename = directive[1].to_s.strip.chomp

          construct_file(inc_filename)
        else
          @file.append(line)
        end
      end
    end

    def assemble_file(pass)
      @file.each_with_index do |raw_line, line_no|
        @line = raw_line

        if @line.include?(':')
          arr = @line.split(':')
          label = arr[0].strip.chomp
          unless /^\w+$/ =~ label
            raise "Invalid label: #{label}"
          end
          register_label(label) if pass == 0
          next unless arr[1]
          instruction = arr[1].strip.chomp
        else
          instruction = @line
        end

        next if instruction.empty?

        if instruction.start_with?(*DIRECTIVE)
          process_directive(instruction, pass)
          next
        end

        begin
          bytes = LineAssembler.new(instruction, **options).assemble
        rescue => e
          puts "Error at line #{line_no + 1}: #{e}"
          exit(1)
        end

        insert(bytes) if pass == 1
        @program_counter += bytes.size
      end
    end

    def register_label(label)
      raise "Label already defined: #{label}" if @label_registry.detect { |l| l[0] == label }
      @label_registry << [label, @program_counter + @origin]
    end

    def insert(bytes, insert_at = insert_index)
      @memory[insert_at..insert_at + bytes.size - 1] = bytes
    end

    def insert_index
      @program_counter + @base
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

    def process_directive(instruction, pass)
      directive = instruction.split(' ')

      case directive[0]
      when '.65816'
        @cpu = WDC65816
      when '.spc700'
        @cpu = SPC700
      when '.org'
        update_origin(directive[1].to_i(16))
      when '.base'
        @base = directive[1].to_i(16)
      when '.incbin'
        @program_counter += prepare_incbin(directive[1].to_s.strip.chomp, pass)
      when '.db'
        raw_line = directive[1..-1].join.to_s.strip.chomp
        line = LineAssembler.new(raw_line, **options).replace_labels(raw_line)

        @program_counter += define_bytes(line, pass)
      when '.rb'
        @program_counter += directive[1].to_i(16)
      end
    end

    def update_origin(param)
      @origin = param
      @program_counter = 0

      update_base_from_origin
    end

    def update_base_from_origin
      # TODO: automatically update base
      # lorom/hirom scheme
      # spc700 scheme
    end

    def prepare_incbin(filename, pass)
      raise "Incbin: file not found: #{filename}" unless File.file?(filename)

      @incbin_list << [filename, insert_index] if pass == 0
      File.size(filename) || 0
    end

    def incbin
      @incbin_list.each do |filename, index|
        file = File.open(filename)
        bytes = file.each_byte.to_a
        @line = filename
        insert(bytes, index)
      end
    end

    def define_bytes(raw_bytes, pass)
      bytes = raw_bytes.split(',').map { |rb| rb.scan(/.{2}/).reverse }.flatten.map do |b|
        bv = b.to_i(16)
        raise "Invalid byte: #{b} : #{@line}" if bv < 0 || bv > 0xff
        bv
      end

      @byte_sequence_list << [bytes, insert_index] if pass == 0
      bytes.size
    end

    def insert_bytes
      @byte_sequence_list.each do |bytes, index|
        insert(bytes, index)
      end
    end

    def write_label_registry
      longest = @label_registry.map{|r| r[0] }.max_by(&:length)

      File.open('labels.txt', 'w+b') do |file|
        @label_registry.each do |label|
          adjusted_label = label[0].ljust(longest.length, ' ')
          raw_address = Vas::hex(label[1], 6)
          address = "#{raw_address[0..1]}/#{raw_address[2..-1]}"
          file.write "#{adjusted_label} #{address}\n"
        end
      end
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

      raw_operand = replace_label(raw_operand)

      opcode_data = detect_opcode(mnemonic, raw_operand)
      raise "Invalid syntax" unless opcode_data

      opcode = opcode_data[:opcode]
      @mode = opcode_data[:mode]
      @length = opcode_data[:length]

      operand_data = detect_operand(raw_operand)

      operand = process_operand(operand_data)

      return [opcode, *operand]
    end

    def contains_label?(operand)
      Vas::LABEL_OPERATORS.any? { |s| operand.include?(s[-1,1]) }
    end

    def replace_labels(operand)
      while contains_label?(operand)
        operand = replace_label(operand)
      end

      operand
    end

    def replace_label(operand)
      return operand unless contains_label?(operand)

      unless matches = /(#{Vas::LABEL_OPERATORS.join('|')})(\w+)(\+(\d+))?/.match(operand)
          raise "Invalid label syntax: #{operand}"
      end

      mode = matches[1]
      label = matches[2]
      offset = matches[4].to_i

      label_data = @label_registry.detect { |l| l[0] == label }

      value = label_data ? label_data[1] : @current_address

      value += offset

      case mode
      when '@'
        value = value & 0x00ffff
        new_value = Vas::hex(value, 4)
      when '!'
        value = value | (((@current_address >> 16) & 0xff) << 16)
        new_value = Vas::hex(value, 6)
      when '<'
        value = value & 0x0000ff
        new_value = Vas::hex(value)
      when '>'
        value = (value & 0x00ff00) >> 8
        new_value = Vas::hex(value)
      when '^'
        mode = '\^'
        value = (value & 0xff0000) >> 16
        new_value = Vas::hex(value)
      else
        raise "Mode error: #{mode}"
      end

      operand.gsub(/(#{mode})\w+(\+(\d+))?/, new_value)
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
      raise "Out of range: m > 0x1fff: #{m}" if m > 0x1fff

      b = operand_data[2].to_i(16)
      raise "Out of range: b > 7: #{b}" if b > 7

      little_endian(m << 3 | b, 2)
    end

    def process_rel_operand(operand)
      relative_addr = operand - (@current_address & 0x00ffff) - @length

      if @cpu == Vas::WDC65816 && @mode == :rell
        raise "Relative address out of range: #{relative_addr}" if relative_addr < -32_768 || relative_addr > 32_767

        relative_addr += 0x10000 if relative_addr < 0
        little_endian(relative_addr, 2)
      else
        raise "Relative address out of range: #{relative_addr}" if relative_addr < -128 || relative_addr > 127

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
