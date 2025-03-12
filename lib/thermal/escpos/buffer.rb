# frozen_string_literal: true

module Thermal
module Escpos
  # Inspired by mike42/escpos-php
  # https://github.com/mike42/escpos-php/blob/development/src/Mike42/Escpos/PrintBuffers/EscposPrintBuffer.php
  class Buffer < ::Thermal::ByteBuffer
    extend Forwardable

    def initialize(profile)
      super()
      @profile = profile
      @codepage = 0
      @charset = 0
      @cjk = false
      init_buffer!
    end

    def_delegators :@profile,
                   :find_encoding,
                   :cjk_encoding,
                   :codepages,
                   :charsets,
                   :codepoint_cjk_skip?,
                   :codepoint_cjk_force?

    def current_encoding
      @cjk ? cjk_encoding : codepages[@codepage]
    end

    def current_charset
      charsets[@charset]
    end

    def write_text(text, replace: nil, no_cjk: false)
      text = ::Thermal::Util.normalize_utf8(text, replace: replace)
      text&.each_codepoint do |u_codepoint|
        write_u_codepoint(u_codepoint, replace: replace, no_cjk: no_cjk)
      end
    end

    private

    def write_u_codepoint(u_codepoint, replace: nil, no_cjk: false, fallback: false)
      replace ||= ::Thermal.replace_char

      if ascii?(u_codepoint)
        reset_charset!(u_codepoint)
        write(u_codepoint)
      elsif current_encoding &&
            (!@cjk || (!no_cjk && !codepoint_cjk_skip?(u_codepoint))) &&
            (@cjk || !codepoint_cjk_force?(u_codepoint)) &&
            (codepoint = current_encoding.codepoint(u_codepoint))
        write(codepoint)
      else
        location, value = find_encoding(u_codepoint, no_cjk: no_cjk)
        case location
        when :codepage
          set_codepage(value)
          codepoint = current_encoding.codepoint(u_codepoint)
          # TODO: move this to encoding class
          raise_missing_codepoint!(u_codepoint, current_encoding) unless codepoint
          write(codepoint)
        when :charset
          set_charset(value)
          codepoint = current_charset.codepoint(u_codepoint)
          # TODO: move this to encoding class
          raise_missing_codepoint!(u_codepoint, current_encoding) unless codepoint
          write(codepoint)
        when :cjk
          set_cjk(true)
          char = current_encoding.codepoint(u_codepoint)
          # TODO: move this to encoding class
          raise_missing_codepoint!(u_codepoint, current_encoding) unless char
          write(char)
        else
          write_u_codepoint(replace.ord, replace: ' ', fallback: true) unless fallback || replace.empty?
        end
      end
    end

    def init_buffer!
      sequence(::Escpos::HW_INIT)

      # CJK is on after HW_INIT for Chinese models.
      # To ensure consistency, we explicitly set it off.
      # https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=175
      sequence(Cmd::SET_CJK_OFF) if cjk_supported?
    end

    def ascii?(codepoint, extended: false)
      (codepoint == 10) ||
        (codepoint >= 32 && codepoint <= 126) ||
        (extended && codepoint >= 128 && codepoint <= 255)
    end

    def set_charset(charset) # rubocop:disable Naming/AccessorMethodName
      return if @charset == charset

      sequence([0x1b, 0x52] + [charset])
      @charset = charset
    end

    def reset_charset!(u_codepoint)
      return unless ::Thermal::Db::Charset::CODEPOINTS.include?(u_codepoint)

      set_charset(0)
    end

    def set_codepage(codepage) # rubocop:disable Naming/AccessorMethodName
      set_cjk(false)
      return if @codepage == codepage

      sequence(::Escpos::CP_SET + [codepage])
      @codepage = codepage
    end

    def set_cjk(enabled) # rubocop:disable Naming/AccessorMethodName
      enabled ? set_cjk_on : set_cjk_off
    end

    def set_cjk_on
      return if !cjk_supported? || @cjk

      sequence(cjk_on_command)
      @cjk = true
    end

    def set_cjk_off
      return if !cjk_supported? || !@cjk

      sequence(cjk_off_command)
      @cjk = false
    end

    def cjk_supported?
      !!cjk_encoding
    end

    def shift_jis?
      cjk_encoding&.ruby == 'Shift_JIS'
    end

    def cjk_on_command
      if shift_jis?
        Cmd::SET_JIS_MODE + [1]
      else
        Cmd::SET_CJK_ON
      end
    end

    def cjk_off_command
      if shift_jis?
        Cmd::SET_JIS_MODE + [0]
      else
        Cmd::SET_CJK_OFF
      end
    end

    # TODO: move this to encoding
    def raise_missing_codepoint!(u_codepoint, encoding)
      klass = encoding.class.name.split('::').last
      raise "Codepoint U#{u_codepoint.to_s(16)} not found in #{klass} #{encoding.name}"
    end
  end
end
end
