# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Thermal::EscposStar::Writer do
  let(:profile) { instance_double(Thermal::Profile) }
  let(:writer) { described_class.new(profile) }
  let(:buffer) { instance_double(Thermal::EscposStar::Buffer) }

  before do
    allow(Thermal::EscposStar::Buffer).to receive(:new).and_return(buffer)
    allow(buffer).to receive(:write_text)
    allow(buffer).to receive(:sequence)
  end

  it 'has the correct format' do
    expect(described_class.format).to eq 'escpos_star'
  end

  describe '#text' do
    it 'feeds by default' do
      expect(writer).to receive(:feed)
      writer.text("Hello")
    end

    it 'does not feed when feed: false' do
      expect(writer).not_to receive(:feed)
      writer.text("Hello", feed: false)
    end
  end

  describe '#feed' do
    it 'writes newline characters to the buffer' do
      expect(buffer).to receive(:write).with("\n\n\n")
      writer.feed(3)
    end
  end
end
