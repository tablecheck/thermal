# frozen_string_literal: true

module Thermal
module Db
  module Data
    extend self

    MUTEX = Mutex.new
    DATA_PATH = 'data/db.yml'

    def data
      MUTEX.synchronize do
        @data ||= begin
          data = load_data
          normalize_data!(data)
          ::Thermal::Util.deep_freeze!(data)
          data
        end
      end
    end

    def available_devices
      data['devices']
    end

    def available_encodings
      data['encodings']
    end

    def available_charsets
      data['charsets']
    end

    def device(device)
      return unless device

      data.dig('devices', device.to_s)
    end

    def encoding(encoding)
      return unless encoding

      data.dig('encodings', encoding.to_s)
    end

    def charset(charset)
      return unless charset

      data.dig('charsets', 'escpos', charset.to_i)
    end

    def reload
      MUTEX.synchronize do
        @data = nil
      end
    end

    private

    def data_path
      ::Thermal.gem_root.join(DATA_PATH).to_s
    end

    def load_data
      YAML.load_file(data_path, aliases: true)
    end

    def normalize_data!(data)
      data.dig('charsets', 'escpos').transform_keys!(&:to_i)
      device_int_keys = %w[codepages colors fonts]
      data['devices'].each_value do |d|
        device_int_keys.each { |k| d[k]&.transform_keys!(&:to_i) }
      end
    end
  end
end
end
