require 'yaml'
require 'readline'

def write(nbytes)
  data = (1..nbytes).map { |b| '00' }
  File.open('test.bin', 'w+b') do |file|
    file.write([data.join].pack('H*'))
  end
end

class MiniAssembler
  MODES_REGEXES = {
    acc: /^$/,
    imp: /^$/,
    imm: /^\$?([0-9a-f]{1,2})$/i,
    iml: /^\$?([0-9a-f]{1,2})$/i,
    imm8: /^#\$?([0-9a-f]{1,2})$/i,
    imm16: /^#\$?([0-9a-f]{3,4})$/i,
    sr: /^\$?([0-9a-f]{1,2}),S$/i,
    dp: /^\$?([0-9a-f]{1,2})$/i,
    dpx: /^\$?([0-9a-f]{1,2}),X$/i,
    dpy: /^\$?([0-9a-f]{1,2}),Y$/i,
    idp: /^\(\$?([0-9a-f]{1,2})\)$/i,
    idx: /^\(\$?([0-9a-f]{1,2}),X\)$/i,
    idy: /^\(\$?([0-9a-f]{1,2})\),Y$/i,
    idl: /^\[\$?([0-9a-f]{1,2})\]$/i,
    idly: /^\[\$?([0-9a-f]{1,2})\],Y$/i,
    isy: /^\(\$?([0-9a-f]{1,2}),S\),Y$/i,
    abs: /^\$?([0-9a-f]{3,4})$/i,
    abx: /^\$?([0-9a-f]{3,4}),X$/i,
    aby: /^\$?([0-9a-f]{3,4}),Y$/i,
    abl: /^\$?([0-9a-f]{5,6})$/i,
    alx: /^\$?([0-9a-f]{5,6}),X$/i,
    ind: /^\(\$?([0-9a-f]{3,4})\)$/i,
    iax: /^\(\$?([0-9a-f]{3,4}),X\)$/i,
    ial: /^\[\$?([0-9a-f]{3,4})\]$/i,
    rel: /^\$?([0-9a-f]{3,4})$/i,
    rell: /^\$?([0-9a-f]{3,4})$/i,
    bm: /^\$?([0-9a-f]{1,2}),\$?([0-9a-f]{1,2})$/i
  }

  def initialize
    @normal_mode = true
    @lorom = true
    @bank_size = @lorom ? 0x8000 : 0x10000
    @memory = (0..255).map { |bank| (1..@bank_size).map { |b| rand(0..255).to_s(16).rjust(2, '0') } }
    @current_addr = 0
    @current_bank_no = 0
  end

  def current_bank
    @memory[@current_bank_no]
  end

  def getline
    prompt = @normal_mode ? '*' : '!'
    Readline.readline(prompt, true).strip.chomp
  end

  def parse_line(line)
    if @normal_mode
      if line == '!'
        @normal_mode = false
        return
      elsif /^[0-9a-fA-F]+$/ =~ line
        return current_bank[line.to_i(16)]
      elsif matches = /^([0-9a-fA-F]+)\.+([0-9a-fA-F]+)$/.match(line)
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
      elsif matches = /^([0-9a-fA-F]+):([0-9a-fA-F ]+)$/.match(line)
        addr = matches[1].to_i(16)
        bytes = matches[2].delete(' ').scan(/.{1,2}/).map { |b| b.to_i(16).to_s(16).rjust(2, '0') }
        current_bank[addr..addr+bytes.length-1] = bytes
        return
      elsif matches = /^([0-9a-fA-F]{2})\/$/.match(line)
        # check if memory has enough bank.
        # lowrom bank size = 0x8000
        # hirom bank size =  0x10000
        @current_bank_no = matches[1].to_i(16)
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
