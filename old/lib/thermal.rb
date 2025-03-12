$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'thermal/version'
require 'thermal/printer'
require 'thermal/parser'

require 'devices/html'
require 'devices/btpr880'
