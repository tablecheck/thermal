# frozen_string_literal: true

module Thermal
module Escpos
  class Writer < ::Thermal::WriterBase
    extend Forwardable

    DEFAULT_QR_CODE_SIZE = 400

    def_delegators :buffer,
                   :write,
                   :write_text,
                   :sequence

    def self.format
      'escpos'
    end

    def print(flush: true, output: nil)
      @buffer = nil
      super
      feed(5)
      cut
      if output == :byte_array
        flush ? buffer.flush : buffer.to_a
      else
        flush ? buffer.flush_base64 : buffer.to_base64
      end
    end

    def text(str, feed: true, replace: nil, no_cjk: false, **_kwargs)
      write_text(str, replace: replace, no_cjk: no_cjk)
      self.feed if feed
    end

    def hr(style = nil, width: col_width)
      write_text(hr_char(style) * width)
      feed
    end

    def feed(lines = 1)
      write("\n" * lines)
    end

    def cut
      seq = supports?(:paper_partial_cut) ? ::Escpos::PAPER_PARTIAL_CUT : ::Escpos::PAPER_FULL_CUT
      sequence(seq)
    end

    def image(path, opts = {})
      write(::Escpos::Image.new(path, opts).to_escpos)
    end

    def qr_code(url, size = DEFAULT_QR_CODE_SIZE)
      image(::RQRCode::QRCode.new(url).as_png(size: size))
    end

    private

    def write_bold!
      cmd = @bold ? ::Escpos::TXT_BOLD_ON : ::Escpos::TXT_BOLD_OFF
      sequence(cmd)
    end

    def write_underline!
      cmd = if !@underline
              ::Escpos::TXT_UNDERL_OFF
            elsif @underline.is_a?(Numeric) && @underline >= 2
              ::Escpos::TXT_UNDERL2_ON
            else
              ::Escpos::TXT_UNDERL_ON
            end
      sequence(cmd)
    end

    def write_align!
      cmd = case @align
            when :right
              ::Escpos::TXT_ALIGN_RT
            when :center
              ::Escpos::TXT_ALIGN_CT
            else
              ::Escpos::TXT_ALIGN_LT
            end
      sequence(cmd)
    end

    def buffer
      @buffer ||= ::Thermal::Escpos::Buffer.new(@profile)
    end
  end
end
end
