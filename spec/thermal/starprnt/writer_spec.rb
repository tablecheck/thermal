# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Thermal::Starprnt::Writer do
  let(:profile) { instance_double(Thermal::Profile) }
  let(:writer) { described_class.new(profile) }
  let(:buffer) { instance_double(Thermal::Starprnt::Buffer) }

  before do
    allow(Thermal::Starprnt::Buffer).to receive(:new).and_return(buffer)
    allow(buffer).to receive(:print)
  end

  it 'has the correct format' do
    expect(described_class.format).to eq 'starprnt'
  end

  describe '#text' do
    it 'appends text to the buffer' do
      expect(buffer).to receive(:print).with(append: "Hello\n")
      writer.text("Hello")
    end

    it 'does not append newline when feed: false' do
      expect(buffer).to receive(:print).with(append: "Hello")
      writer.text("Hello", feed: false)
    end

    it 'normalizes text' do
      expect(Thermal::Util).to receive(:normalize_utf8).with("Hello", replace: nil).and_return("Hello")
      writer.text("Hello")
    end
  end

  describe '#feed' do
    it 'appends line feed to the buffer' do
      expect(buffer).to receive(:print).with(appendLineFeed: 3)
      writer.feed(3)
    end
  end
end
