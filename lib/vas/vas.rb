require 'securerandom'

module SnesUtils
  class Vas
    WDC65816 = :wdc65816
    SPC700 = :spc700
    SUPERFX = :superfx

    DIRECTIVE = [
      '.65816', '.spc700', '.superfx', '.org', '.base', '.db', '.rb', '.incbin'
    ]

    LABEL_OPERATORS = ['@', '!', '<', '>', '\^']

    def initialize(filename, outfile)
      raise "File not found: #{filename}" unless File.file?(filename)

      @filename = filename
      @outfile = outfile
      @file = []
      @label_registry = []
      @reading_macro = false
      @current_macro = nil
      @macros_registry = {}
      @define_registry = {}
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
      write(@outfile)
    end

    def construct_file(filename = @filename)
      File.open(filename).each_with_index do |raw_line, line_no|
        line = raw_line.split(';').first.strip.chomp
        next if line.empty?

        if line.start_with?('.include')
          raise "can't include file within macro" if @reading_macro

          directive = line.split(' ')
          inc_filename = directive[1].to_s.strip.chomp
          dir = File.dirname(filename)

          construct_file(File.join(dir, inc_filename))
        elsif line.start_with?('.define')
          raise "can't define variable within macro" if @reading_macro

          args = line.split(' ')
          key = "#{args[1]}"
          raw_val = args[2..-1].join(' ').split(';').first
          raise "Missing value for : #{key}" if raw_val.nil?

          val = raw_val.strip.chomp

          raise "Already defined: #{key}" unless @define_registry[key].nil?
          @define_registry[key] = val
        elsif line.start_with?('.call')
          raise "can't call macro within macro" if @reading_macro

          args = line.split(' ')
          macro_name = args[1]
          macro_args = args[2..-1].join.split(',')
          call_macro(macro_name, macro_args, line_no + 1)
        elsif line.start_with?('.macro')
          raise "can't have nested macro" if @reading_macro

          args = line.split(' ')
          macro_name = args[1]
          macro_args = args[2..-1].join.split(',')
          init_macro(macro_name, macro_args)
        else
          new_line = replace_define(line)
          line_info = { line: new_line, orig_line: line, line_no: line_no + 1, filename: filename }

          if @reading_macro
            line.start_with?('.endm') ? save_macro : @current_macro[:lines] << line_info
          else
            @file << line_info
          end
        end
      end
    end

    def init_macro(name, args)
      @current_macro = { name: name, args: args, lines: [] }
      @reading_macro = true
    end

    def save_macro
      name = @current_macro[:name]
      raise "macro `#{name}` already defined" unless @macros_registry[name].nil?
      @macros_registry[name] = @current_macro
      @reading_macro = false
    end

    def call_macro(name, raw_args, line_no)
      macro = @macros_registry[name]
      uuid = SecureRandom.uuid
      raise "line #{line_no}: call of undefined macro `#{name}`" if macro.nil?

      args_names = @macros_registry[name][:args]
      if args_names.count != raw_args.count
        raise "line #{line_no}: wrong number of arguments for macro `#{name}` expected : #{args_names.count}, given: #{raw_args.count}"
      end
      args = {}
      args_names.count.times do |i|
        args[args_names[i]] = raw_args[i]
      end

      macro[:lines].each_with_index do |line_info|
        line = line_info[:line]

        if line.include?('%')
          # replace variable with arg
          matches = line.match(/%(\w+)%?/)
          if matches[1] == 'MACRO_ID'
            value = uuid.delete('-')
          else
            value = args[matches[1]]
          end
          raise "line #{line_no}: undefined variable `#{matches[1]}` for macro `#{name}`" if value.nil?
          replaced_line = line.gsub(/#{matches[0]}/, value)
          @file << line_info.merge(line: replace_define(replaced_line))
        else
          @file << line_info
        end
      end
    end

    def replace_define(line)
      found = nil

      @define_registry.keys.each do |key|
        if line.match(/\b#{key}\b/)
          found = key
          break
        end
      end


      return line if found.nil?

      val = @define_registry[found]

      line.gsub(/\b#{found}/, val)
    end

    def assemble_file(pass)
      @file.each do |line|
        @line = line[:line]

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
          process_directive(instruction, pass, line)
          next
        end

        begin
          bytes = LineAssembler.new(instruction, **options).assemble
        rescue => e
          puts "Error at line #{line[:filename]}##{line[:line_no]} - (#{line[:orig_line]}) : #{e}"
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

    def write(filename)
      if filename.nil?
        dir = File.dirname(@filename)
        filename = File.join(dir, 'out.sfc')
      end

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

    def process_directive(instruction, pass, line_info)
      directive = instruction.split(' ')

      case directive[0]
      when '.65816'
        @cpu = WDC65816
      when '.spc700'
        @cpu = SPC700
      when '.superfx'
        @cpu = SUPERFX
      when '.org'
        update_origin(directive[1].to_i(16))
      when '.base'
        @base = directive[1].to_i(16)
      when '.incbin'
        inc_filename = directive[1].to_s.strip.chomp
        dir = File.dirname(line_info[:filename])
        @program_counter += prepare_incbin(File.join(dir, inc_filename), pass)
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

      if @outfile.nil?
        dir = File.dirname(@filename)
      else
        dir = File.dirname(@outfile)
      end

      File.open(File.join(dir, 'labels.txt'), 'w+b') do |file|
        @label_registry.each do |label|
          adjusted_label = label[0].ljust(longest.length, ' ')
          raw_address = Vas::hex(label[1], 6)
          address = "#{raw_address[0..1]}/#{raw_address[2..-1]}"
          file.write "#{adjusted_label} #{address}\n"
        end
      end
      File.open(File.join(dir, 'labels.msl'), 'w+b') do |file|
        @label_registry.each do |label|
          if label[1] >= 0x7e0000 && label[1] <= 0x7fffff
            bank = label[1] & 0xff0000
            address = "WORK:#{Vas::hex(label[1] - bank)}:#{label[0]}:"
          else
            bank = label[1] & 0xff0000
            bank_i = bank >> 16 & 0xf
            # low rom only for now
            prg_addr = label[1] - bank - 0x8000 + bank_i * 0x8000
            address = "PRG:#{Vas::hex(prg_addr)}:#{label[0]}:"
          end
          file.write "#{address}\n"
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
        value = value # | (((@current_address >> 16) & 0xff) << 16) # BUG HERE
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

    def alt_instruction?(mnemonic)
      SnesUtils.const_get(@cpu.capitalize)::Definitions::ALT_INSTRUCTIONS.include?(mnemonic.downcase.to_sym)
    end

    def sgl_instruction?(mnemonic)
      SnesUtils.const_get(@cpu.capitalize)::Definitions::SGL_INSTRUCTIONS.include?(mnemonic.downcase.to_sym)
    end

    def dbl_instruction?(mnemonic)
      SnesUtils.const_get(@cpu.capitalize)::Definitions::DBL_INSTRUCTIONS.include?(mnemonic.downcase.to_sym)
    end
  end
end
