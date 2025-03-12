# frozen_string_literal: true

require_relative 'lib/thermal/version'

Gem::Specification.new do |spec|
  spec.name          = 'thermal'
  spec.version       = Thermal::VERSION
  spec.authors       = ['Johnny Shields']
  spec.email         = ['johnny.shields@gmail.com']
  spec.homepage      = 'https://github.com/tablecheck/thermal'
  spec.summary       = 'Thermal printer support for Ruby'
  spec.description   = 'Thermal printer support for Ruby. Used to print receipts, chits, tickets, labels, etc.'

  spec.files         = Dir['{lib,data}/**/*'] + %w[README.md LICENSE]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0'
  spec.add_dependency 'base64', '>= 0'
  spec.add_dependency 'escpos', '< 1.0.0'
  spec.add_dependency 'escpos-image', '< 1.0.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
