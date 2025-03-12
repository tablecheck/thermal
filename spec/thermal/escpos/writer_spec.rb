# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe ::Thermal::Escpos::Writer do
  it do
    expect(described_class.format).to eq 'escpos'
  end

  # TODO: test #text no_cjk option
  # TODO: test random kwargs to #text
end
