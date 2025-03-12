# frozen_string_literal: true

require 'forwardable'
require 'yaml'
require 'fileutils'
require 'pathname'

require 'escpos' # TODO: get rid of this

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'thermal/version'
require 'thermal/util'
require 'thermal/writer_base'
require 'thermal/byte_buffer'
require 'thermal/db/data'
require 'thermal/db/loader'
require 'thermal/db/charset'
require 'thermal/db/cjk_encoding'
require 'thermal/db/device'
require 'thermal/db/encoding'
require 'thermal/db'
require 'thermal/escpos/cmd'
require 'thermal/escpos/buffer'
require 'thermal/escpos/writer'
require 'thermal/escpos_star/buffer'
require 'thermal/escpos_star/writer'
require 'thermal/stargraphic/capped_byte_buffer'
# require 'thermal/stargraphic/chunked_byte_buffer'
require 'thermal/stargraphic/writer'
require 'thermal/starprnt/buffer'
require 'thermal/starprnt/writer'
require 'thermal/profile'
require 'thermal/printer'
require 'thermal/dsl'

module Thermal
  class << self
    DEFAULT_REPLACE_CHAR = ' '
    DEFAULT_TMP_DIR = 'tmp/thermal'

    attr_reader :tmp_dir

    def replace_char
      @replace_char ||= DEFAULT_REPLACE_CHAR
    end

    def replace_char=(value)
      @replace_char = value || ''
    end

    def tmp_path(filename)
      raise 'Must set Thermal.tmp_dir' unless tmp_dir || app_root

      path = tmp_dir ? Pathname.new(tmp_dir) : app_root.join(DEFAULT_TMP_DIR)
      path = path.join(filename)
      FileUtils.mkdir_p(File.dirname(path))
      path
    end

    def tmp_dir=(value)
      unless value
        @tmp_dir = nil
        return
      end

      value = Pathname.new(value)
      raise ArgumentError.new('Thermal.tmp_dir must be an absolute path') unless value.absolute?

      @tmp_dir = value
    end

    def app_root
      Rails.root if defined?(::Rails)
    end

    def gem_root
      Pathname.new(File.expand_path('..', __dir__))
    end
  end
end
