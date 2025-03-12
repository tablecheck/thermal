# frozen_string_literal: true

module Thermal
module Db
  # Adds CJK character encoding lookup.
  class CjkEncoding
    attr_reader :key, :ruby

    def initialize(key, ruby)
      @key = key
      @ruby = ruby
    end

    def codepoint(u_codepoint)
      char(u_codepoint.chr('UTF-8'))
    rescue RangeError
      nil
    end

    def codepoint?(u_codepoint)
      !!codepoint(u_codepoint)
    end

    def char(u_char)
      return if u_char.ord <= 127
      char = u_char.encode(@ruby)
      char unless skip?(char)
    rescue EncodingError
      nil
    end

    def char?(u_char)
      !!char(u_char)
    end

    private

    def skip?(char)
      # GB18030 has a 4-byte mapping into Unicode which should be skipped.
      # Refer to: https://en.wikipedia.org/wiki/GB_18030#Mapping
      @ruby == 'GB18030' && char&.bytes&.size == 4
    end
  end
end
end
