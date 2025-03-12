# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Thermal::Escpos::Writer do
  let(:profile) { instance_double(Thermal::Profile) }
  let(:writer) { described_class.new(profile) }
  let(:buffer) { instance_double(Thermal::Escpos::Buffer) }

  before do
    allow(Thermal::Escpos::Buffer).to receive(:new).and_return(buffer)
    allow(buffer).to receive(:write_text)
    allow(buffer).to receive(:write)
    allow(buffer).to receive(:sequence)
  end

  it 'has the correct format' do
    expect(described_class.format).to eq 'escpos'
  end

  describe '#text' do
    it 'writes text to the buffer' do
      expect(buffer).to receive(:write_text).with('Hello', replace: nil, no_cjk: false)
      writer.text('Hello')
    end

    it 'accepts no_cjk option' do
      expect(buffer).to receive(:write_text).with('Hello', replace: nil, no_cjk: true)
      writer.text('Hello', no_cjk: true)
    end

    it 'accepts replace option' do
      expect(buffer).to receive(:write_text).with('Hello', replace: '_', no_cjk: false)
      writer.text('Hello', replace: '_')
    end

    it 'feeds by default' do
      expect(writer).to receive(:feed)
      writer.text('Hello')
    end

    it 'does not feed when feed: false' do
      expect(writer).not_to receive(:feed)
      writer.text('Hello', feed: false)
    end
  end

  describe '#feed' do
    it 'writes newline characters to the buffer' do
      expect(buffer).to receive(:write).with("\n\n\n")
      writer.feed(3)
    end
  end
end
