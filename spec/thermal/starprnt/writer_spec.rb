# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe ::Thermal::Starprnt::Writer do
  it do
    expect(described_class.format).to eq 'starprnt'
  end

  # TODO: test random kwargs to #text
end
