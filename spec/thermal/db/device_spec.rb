# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Thermal::Db::Device do
  let(:cfg) { Thermal::Db::Data.data.dig('devices', device) }
  let(:obj) { described_class.new(device, cfg) }

  context 'epson_tm_t88v' do
    let(:device) { 'epson_tm_t88v' }

    it do
      expect(obj.codepages.keys).to eq [0, 1, 2, 3, 4, 5, 16, 17, 18, 19]
      expect(obj.codepages.values.map(&:key)).to eq %w[cp437 katakana cp850 cp860 cp863 cp865 cp1252 cp866 cp852 cp858]
      expect(obj.charsets.keys).to eq (0..17).to_a
      expect(obj.charsets.values.map(&:key)).to eq (0..17).to_a

      expect(obj.find_encoding('A'.ord)).to be_nil
      expect(obj.find_encoding('♠'.ord)).to eq [:codepage, 1]
      expect(obj.find_encoding('₧'.ord)).to eq [:codepage, 0]
      expect(obj.find_encoding('Д'.ord)).to eq [:codepage, 17]
      expect(obj.find_encoding('₩'.ord)).to eq [:charset, 13]
      expect(obj.find_encoding('¥'.ord)).to eq [:codepage, 0]
      expect(obj.find_encoding('€'.ord)).to eq [:codepage, 16]
    end
  end
end
