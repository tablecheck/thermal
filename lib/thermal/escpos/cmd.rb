# frozen_string_literal: true

module Thermal
module Escpos
  module Cmd
    SET_JIS_MODE = [0x1C, 0x43].freeze
    SET_CJK_ON   = [0x1C, 0x26].freeze
    SET_CJK_OFF  = [0x1C, 0x2E].freeze
  end
end
end
