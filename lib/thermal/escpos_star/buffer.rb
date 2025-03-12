# frozen_string_literal: true

module Thermal
module EscposStar
  class Buffer < ::Thermal::ByteBuffer

    def initialize
      super
      init_buffer!
    end

    def write_text(text, replace: nil, **_kwargs)
      text = ::Thermal::Util.normalize_utf8(text, replace: replace)
      write(text) if text
    end

    private

    def init_buffer!
      sequence(::Escpos::HW_INIT)
      set_cjk_off
      set_charset_zero
      set_codepage_utf8
    end

    def set_cjk_off
      sequence([ 0x1c, 0x2e,
                 0x1c, 0x43, 0 ])
    end

    def set_charset_zero
      sequence([0x1b, 0x52, 0])
    end

    def set_codepage_utf8
      sequence([0x1b, 0x1d, 0x74, 128])
    end
  end
end
end
