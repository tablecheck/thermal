# frozen_string_literal: true

module Thermal
module Starprnt
  class Writer < ::Thermal::WriterBase
    DEFAULT_QR_CODE_CELL_SIZE = 4

    def print(flush: true, output: nil)
      set_utf8_encoding
      super
      feed(5)
      cut
      flush ? buffer.flush : buffer.to_a
    end

    def self.format
      'starprnt'
    end

    def text(str, feed: true, replace: nil, **_kwargs)
      str = ::Thermal::Util.normalize_utf8(str, replace: replace)
      str = "#{str}\n" if feed
      write(str) if str
    end

    def hr(style = nil, width: col_width)
      write("#{hr_char(style) * width}\n")
    end

    def write_bold!
      buffer.print(enableEmphasis: !!@bold)
    end

    def write_underline!
      buffer.print(enableUnderline: !!@underline)
    end

    def write_align!
      cmd = case @align
            when :right
              'Right'
            when :center
              'Center'
            else
              'Left'
            end
      buffer.print(appendAlignment: cmd)
    end

    def feed(lines = 1)
      buffer.print(appendLineFeed: lines)
    end

    def image(path, opts = {})
      buffer.print_base64_image(::Escpos::Image.new(path, opts).to_escpos)
    end

    def qr_code(url, cell_size = DEFAULT_QR_CODE_CELL_SIZE)
      buffer.print(appendQrCode: url, alignment: 'Center', cell: cell_size)
    end

    def cut
      buffer.print(appendCutPaper: 'PartialCut')
    end

    protected

    def write(str)
      buffer.print(append: str)
    end

    def set_utf8_encoding
      buffer.print(appendEncoding: 'UTF-8')
    end

    def buffer
      @buffer ||= ::Thermal::Starprnt::Buffer.new
    end
  end
end
end
