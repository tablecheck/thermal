# frozen_string_literal: true

module Thermal
module Db
  module Loader
    extend self

    MUTEX = Mutex.new

    def device(device)
      device = device&.to_s
      cached(:devices, device) do
        cfg = data.device(device)
        ::Thermal::Db::Device.new(device, cfg) if cfg
      end
    end

    def encoding(encoding)
      encoding = encoding&.to_s
      cached(:encodings, encoding) do
        charmap = data.encoding(encoding)&.[]('charmap')
        ::Thermal::Db::Encoding.new(encoding, charmap) if charmap
      end
    end

    def charset(charset)
      charset = charset&.to_i
      cached(:charsets, charset) do
        charmap = data.charset(charset)&.[]('charmap')
        ::Thermal::Db::Charset.new(charset, charmap) if charmap
      end
    end

    def cjk_encoding(cjk)
      cjk = cjk&.to_s
      cached(:cjk_encodings, cjk) do
        ruby = data.encoding(cjk)&.[]('ruby')
        ::Thermal::Db::CjkEncoding.new(cjk, ruby) if ruby
      end
    end

    def reload
      MUTEX.synchronize do
        @cache = nil
      end
    end

    private

    def cached(key, value)
      key = key.to_s
      return cache.dig(key, value) if cache[key]&.key?(value)
      cache[key] ||= {}
      cache[key][value] = yield
    end

    def cache
      MUTEX.synchronize do
        @cache ||= Concurrent::Hash.new
      end
    end

    def data
      ::Thermal::Db::Data
    end
  end
end
end
