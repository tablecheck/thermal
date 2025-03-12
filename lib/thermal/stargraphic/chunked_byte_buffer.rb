# frozen_string_literal: true

module Thermal
module Stargraphic
  # TODO: This is not used yet.
  # It should be refactored as it doesn't transparently extend ByteBuffer
  class ChunkedByteBuffer

    def initialize(max_chunk_bytes)
      @max_chunk_bytes = max_chunk_bytes
      @byte_counter = 0
    end

    def <<(obj)
      check_length(obj)
      append(obj)
    end

    def chunks
      @chunks ||= [::Thermal::ByteBuffer.new]
    end

    def to_base64
      chunks.map(&:to_base64)
    end

    def to_a
      chunks.map(&:to_a)
    end

    def flush
      tmp = chunks
      @chunks = nil
      @byte_counter = 0
      tmp
    end

    def flush_base64
      tmp = to_base64
      flush
      tmp
    end

    protected

    # This method approximates base64 byte counting. The base64 encoded size
    # will be greater than or equal to the raw bytes, so this is safe.
    # Note that `obj` can be either a String or Array; both respond to size.
    def check_length(obj)
      @byte_counter += obj.size
      add_chunk if @byte_counter > @max_chunk_bytes
    end

    def add_chunk
      chunks << ::Thermal::ByteBuffer.new
    end

    def append(obj)
      chunks.last << obj
    end
  end
end
end
