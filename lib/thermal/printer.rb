# frozen_string_literal: true

module Thermal
  class Printer
    extend Forwardable

    # TODO: align(:symbol)
    PRINT_METHODS = %i[ text
                        hr
                        bold
                        underline
                        align
                        feed
                        cut
                        image
                        qr_code ].freeze

    WRITERS = [
      ::Thermal::Escpos::Writer,
      ::Thermal::EscposStar::Writer,
      ::Thermal::Stargraphic::Writer,
      ::Thermal::Starprnt::Writer
    ].freeze

    WRITER_MAP = ::Thermal::Util.index_by(WRITERS, &:format).freeze

    attr_reader :device

    # opts includes :cjk_encoding
    def initialize(device, **opts)
      @device = device
      @opts = opts
    end

    def profile
      @profile ||= ::Thermal::Profile.new(device, **@opts)
    end

    def writer
      @writer ||= WRITER_MAP[format].new(profile)
    end

    def_delegators :profile,
                   :format,
                   :device_name,
                   :codepages,
                   :charsets,
                   :cjk_encoding,
                   :supports?,
                   :col_width

    def_delegators :writer,
                   :print,
                   *PRINT_METHODS
  end
end
