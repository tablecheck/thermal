# frozen_string_literal: true

module Thermal
  module Db
    extend self
    extend Forwardable

    DEFAULT_DEVICE = 'escpos_generic'
    DEFAULT_CODEPAGES = { 0 => 'cp437' }.freeze
    DEFAULT_CHARSETS = [0].freeze

    def_delegators ::Thermal::Db::Data,
                   :data,
                   :available_devices,
                   :available_encodings,
                   :available_charsets

    def_delegators ::Thermal::Db::Loader,
                   :encoding,
                   :charset,
                   :cjk_encoding

    def device(device)
      loader = ::Thermal::Db::Loader
      loader.device(device) || loader.device(DEFAULT_DEVICE)
    end

    def find_cjk_encoding(locale)
      return unless locale

      case locale.to_s.downcase.tr('_', '-')
      when /\Aja(-.+)?\z/, 'jp'
        'shift_jis'
      when /\Ako(-.+)?\z/, 'kr'
        'ksc5601'
      when /\A(zh)?-?(hant(-.+)?|tw|hk|mo)\z/
        'big5'
      when /\Azh(-.+)?\z/, 'zhhans', 'cn', 'sg', 'my'
        'gb18030'
      end
    end
  end
end
