# frozen_string_literal: true

module Thermal
module Stargraphic
  class CappedByteBuffer < ByteBuffer
    def initialize(max_bytes)
      super()
      @max_bytes = max_bytes
      @byte_counter = 0
    end

    protected

    def append(*bytes)
      @byte_counter += bytes.size
      super unless @byte_counter >= @max_bytes
    end
  end
end
end
