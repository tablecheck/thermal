# frozen_string_literal: true

module Thermal

  # Methods in this class are lovingly borrowed from ActiveSupport
  module Util
    extend self

    def normalize_utf8(text, replace: nil, unf: :nfc)
      return if !text || text.empty? # rubocop:disable Rails/Blank
      replace ||= ::Thermal.replace_char
      text = text.encode('UTF-8', invalid: :replace, undef: :replace, replace: replace)
      text.delete!("\r") # not ever used
      text = UNF::Normalizer.normalize(text, unf) if unf
      text unless text.empty?
    end

    def underscore(word)
      word = word.to_s
      return word unless /[A-Z-]/.match?(word)
      word = word.dup
      word.gsub!(/([A-Z]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) { (Regexp.last_match(1) || Regexp.last_match(2)) << "_" }
      word.tr!("-", "_")
      word.downcase!
      word
    end

    def index_by(enumerable)
      if block_given?
        result = {}
        enumerable.each {|elem| result[yield(elem)] = elem }
        result
      else
        enumerable.to_enum(:index_by) { size if respond_to?(:size) }
      end
    end

    def index_with(enumerable, default = (no_default = true))
      if block_given?
        result = {}
        enumerable.each {|elem| result[elem] = yield(elem) }
        result
      elsif no_default
        enumerable.to_enum(:index_with) { size if respond_to?(:size) }
      else
        result = {}
        enumerable.each {|elem| result[elem] = default }
        result
      end
    end

    def deep_freeze!(object)
      case object
      when Hash
        object.each_value {|v| deep_freeze!(v) }
      when Array
        object.each {|j| deep_freeze!(j) }
      end
      object.freeze
    end

    def self.deep_dup(object)
      case object
      when Hash
        object.transform_values {|v| deep_dup(v) }
      when Array
        object.map {|j| deep_dup(j) }
      else
        object.dup
      end
    end
  end
end
