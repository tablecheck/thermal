# frozen_string_literal: true

module Thermal
module EscposStar
  class Writer < ::Thermal::Escpos::Writer

    def self.format
      'escpos_star'
    end

    private

    def buffer
      @buffer ||= ::Thermal::EscposStar::Buffer.new
    end
  end
end
end
