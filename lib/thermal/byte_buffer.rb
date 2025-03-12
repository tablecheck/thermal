# frozen_string_literal: true

module Thermal
  class ByteBuffer
    extend Forwardable

    def buffer
      @buffer ||= []
    end

    def <<(obj)
      case obj
      when String then append(*obj.bytes)
      when Integer then append(obj)
      when Array then append(*obj)
      else raise "Unknown object type: #{obj.class}"
      end
    end
    alias_method :write, :<<
    alias_method :sequence, :<<

    def to_base64
      Base64.strict_encode64(to_s)
    end

    def to_s
      buffer.pack('C*')
    end

    def to_a
      buffer.dup
    end

    # TODO: use .tap method here
    def flush
      tmp = buffer
      @buffer = nil
      tmp
    end

    # TODO: use .tap method here
    def flush_base64
      tmp = to_base64
      flush
      tmp
    end

    def_delegators :buffer, :append
  end
end
