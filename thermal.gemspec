# frozen_string_literal: true

require_relative 'lib/thermal/version'

Gem::Specification.new do |spec|
  spec.name          = 'thermal'
  spec.version       = Thermal::VERSION
  spec.authors       = ['Johnny Shields']
  spec.email         = ['dev@tablecheck.com']
  spec.summary       = 'Thermal printer support for Ruby'
  spec.description   = 'Thermal printer support for Ruby. Used to print receipts, chits, tickets, labels, etc.'

  spec.files         = Dir['{lib,data}/**/*'] + %w[README.md LICENSE]
  spec.require_paths = ['lib']

  spec.add_dependency 'unf'
  spec.add_dependency 'escpos'
  spec.add_dependency 'escpos-image'
end
