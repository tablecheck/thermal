# frozen_string_literal: true

module Thermal
  class Profile
    extend Forwardable

    # TODO: some of these methods can be moved to an Escpos::Encoder class.

    # These characters should always use codepage, even if present
    # in CJK. HR chars have issues with double-printing in CJK encodings
    # on Epson printers. This has been observed on Japanese (Shift-JIS)
    # with \u2500 and Simplified Chinese (GB18030) with \u2584.
    CODEPOINTS_CJK_SKIP = [
      "\u2500".."\u259F", # box drawing + block elements
      "\u2660".."\u2667"  # card suits
    ].map(&:to_a).flatten.join.each_codepoint.to_a.freeze

    # These characters exist in the Katakana codepage,
    # but should use CJK encoding if available.
    CODEPOINTS_CJK_FORCE = '円年月日時分秒〒市区町村人'.each_codepoint.to_a.freeze

    # Wraps a Device object with CJK encoding support.
    def initialize(device, **opts)
      @device_key = device.to_s
      @cjk = ::Thermal::Db.find_cjk_encoding(opts[:cjk_encoding]) || opts[:cjk_encoding]
    end

    def device_name
      device.name
    end

    def cjk_encoding
      return @cjk_encoding if defined?(@cjk_encoding)

      @cjk_encoding = ::Thermal::Db.cjk_encoding(@cjk)
    end

    def_delegators :device,
                   :format,
                   :codepages,
                   :charsets,
                   :supports?,
                   :col_width

    def find_encoding(u_codepoint, no_cjk: false)
      device_encoding = device.find_encoding(u_codepoint)
      if device_encoding && !codepoint_cjk_force?(u_codepoint)
        device_encoding
      elsif !no_cjk && cjk_encoding&.codepoint?(u_codepoint)
        [:cjk, true].freeze
      else # rubocop:disable Lint/DuplicateBranch
        # codepoint_cjk_force failed
        device_encoding
      end
    end

    def codepoint_cjk_skip?(u_codepoint)
      CODEPOINTS_CJK_SKIP.include?(u_codepoint)
    end

    def codepoint_cjk_force?(u_codepoint)
      CODEPOINTS_CJK_FORCE.include?(u_codepoint)
    end

    private

    def device
      @device ||= ::Thermal::Db.device(@device_key)
    end
  end
end
