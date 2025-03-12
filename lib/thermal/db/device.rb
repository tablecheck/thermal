# frozen_string_literal: true

module Thermal
module Db
  class Device
    DEFAULT_COL_WIDTH = 42

    attr_reader :key

    def initialize(key, data)
      @key = key
      @data = data

      # eager load cache
      codepage_index
      charset_index
    end

    def name
      @data['name']&.to_s
    end

    def format
      @data['format']&.to_s
    end

    def supports?(feature)
      !!@data.dig('features', feature)
    end

    # TODO: this needs to be dynamic in the printer
    def col_width
      @col_width ||= @data.dig('fonts', 0, 'columns') || DEFAULT_COL_WIDTH
    end

    def find_encoding(u_codepoint)
      if (codepage = codepage_index[u_codepoint])
        [:codepage, codepage].freeze
      elsif (charset = charset_index[u_codepoint]) && charset > 0
        [:charset, charset].freeze
      end
    end

    # def find_codepage(encoding)
    #   encoding = encoding&.to_s
    #   device.codepages&.invert&.[](encoding) || 0
    # end

    def codepages
      @codepages ||= begin
        codepages = @data['codepages'] || ::Thermal::Db::DEFAULT_CODEPAGES
        codepages.each_with_object({}) do |(k, v), h|
          encoding = ::Thermal::Db.encoding(v)
          h[k] = encoding if encoding
        end.freeze
      end
    end

    def charsets
      @charsets ||= begin
        charsets = @data['charsets'] || ::Thermal::Db::DEFAULT_CHARSETS
        ::Thermal::Util.index_with(charsets) {|i| ::Thermal::Db.charset(i) }.freeze
      end
    end

    private

    def codepage_index
      @codepage_index ||= codepages.map {|k, v| ::Thermal::Util.index_with(v.u_codepoints, k) }
                                   .reverse.inject(&:merge).freeze
    end

    def charset_index
      @charset_index ||= charsets.values.map! {|c| ::Thermal::Util.index_with(c.u_codepoints, c.key) }
                                 .reverse.inject(&:merge).freeze
    end
  end
end
end
