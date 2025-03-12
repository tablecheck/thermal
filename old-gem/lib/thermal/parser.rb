require 'nokogiri'

module Thermal
  class Parser
    attr_accessor :device

    def initialize(device)
      @device = device
    end

    def process(str)
      fragment = Nokogiri::HTML.fragment(str).children
      traverse(fragment)
    end

    def traverse(fragment)
      fragment.map do |node|
        output = ""
        if node.class == Nokogiri::XML::Text
          output << node.content.gsub("\n","")
        elsif node.class == Nokogiri::XML::Element
          output << @device.startCode(node.name)
          output << traverse(node.children)
          output << @device.endCode(node.name)
        end
        output
      end.join('')
    end
  end
end
