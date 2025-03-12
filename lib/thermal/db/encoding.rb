# frozen_string_literal: true

module Thermal
module Db
  class Encoding
    RANGE = (128..255)

    attr_reader :key, :charmap

    def initialize(key, charmap)
      @key = key
      @charmap = Array(charmap)&.join&.freeze
      raise 'Invalid charmap' unless @charmap.size == 128
    end

    def u_codepoints
      return @u_codepoints if defined?(@u_codepoints)

      @u_codepoints = charmap.each_codepoint.to_a
    end

    def char?(char)
      !!charmap&.include?(char)
    end

    def codepoint?(u_codepoint)
      !!u_codepoints&.include?(u_codepoint)
    end

    def codepoint(u_codepoint)
      u_codepoints&.index(u_codepoint)&.+(128)
    end
  end
end
end
