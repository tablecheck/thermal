# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thermal/version'

Gem::Specification.new do |s|
  s.name          = 'thermal'
  s.version       = Thermal::VERSION
  s.authors       = ['Johnny Shields']
  s.email         = ['dev@tablecheck.com']
  s.description   = 'Thermal Printer API adapter'
  s.summary       = 'Receipt printing support for Ruby'

  s.files         = Dir['{lib,data,spec}/**/*'] + %w[README.md COPYRIGHT]
  s.require_paths = ['lib']

  s.add_dependency 'unf'
  s.add_dependency 'escpos'
  s.add_dependency 'escpos-image'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'iconv'
  s.add_development_dependency 'mini_magick'
  s.add_development_dependency 'rqrcode'
end
