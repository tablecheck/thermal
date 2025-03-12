module Thermal
  class Printer

    def self.translate
      {}
    end

    def self.getCode(tag)
      self.translate[tag.to_sym] || ['', '']
    end

    def self.startCode(tag)
      self.getCode(tag)[0]
    end

    def self.endCode(tag)
      self.getCode(tag)[1]
    end

  end
end
