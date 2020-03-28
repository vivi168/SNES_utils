module SnesUtils
  class Vas
    def initialize
    end

    def assemble(filename)
      return 0 unless File.file?(filename)


    end
  end

  class LineParser
    def initialize(raw_line)
      @line = raw_line.split(';').first.strip.chomp
    end

    def assemble
    end

    def detect_opcode
    end

    def detect_operand
    end
  end
end
