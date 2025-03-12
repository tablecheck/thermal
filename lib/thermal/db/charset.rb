# frozen_string_literal: true

module Thermal
module Db

  # The charset is different than the codepage. It controls usage of
  # specific ASCII-range code points such as dollar-sign ($).
  class Charset
    CODEPOINTS = [0x23, 0x24, 0x25, 0x2A, 0x40, 0x5B, 0x5C, 0x5D, 0x5E, 0x60, 0x7B, 0x7C, 0x7D, 0x7E].freeze

    attr_reader :key, :charmap

    def initialize(key, charmap)
      @key = key
      @charmap = Array(charmap)&.join&.freeze
    end

    def u_codepoints
      return @u_codepoints if defined?(@u_codepoints)
      @u_codepoints = @charmap.each_codepoint.to_a
    end

    def char?(char)
      !!charmap&.include?(char)
    end

    def codepoint?(u_codepoint)
      !!codepoints&.include?(u_codepoint)
    end

    def codepoint(u_codepoint)
      CODEPOINTS[u_codepoints&.index(u_codepoint)]
    end
  end
end
end
