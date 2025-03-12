# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe ::Thermal::Profile do
  let(:cjk) { nil }
  let(:obj) { described_class.new(device, cjk_encoding: cjk) }

  context 'epson_tm_t88v' do
    let(:device) { :epson_tm_t88v }

    it 'sets variables correctly' do
      expect(obj.codepages.keys).to eq [0, 1, 2, 3, 4, 5, 16, 17, 18, 19]
      expect(obj.codepages.values.map(&:key)).to eq %w[cp437 katakana cp850 cp860 cp863 cp865 cp1252 cp866 cp852 cp858]
      expect(obj.charsets.keys).to eq (0..17).to_a
      expect(obj.charsets.values.map(&:key)).to eq (0..17).to_a
      expect(obj.cjk_encoding).to be_nil
    end

    it 'finds encodings' do
      expect(obj.find_encoding('A'.ord)).to be_nil
      expect(obj.find_encoding('♠'.ord)).to eq [:codepage, 1]
      expect(obj.find_encoding('₧'.ord)).to eq [:codepage, 0]
      expect(obj.find_encoding('Д'.ord)).to eq [:codepage, 17]
      expect(obj.find_encoding('₩'.ord)).to eq [:charset, 13]
      expect(obj.find_encoding('¥'.ord)).to eq [:codepage, 0]
      expect(obj.find_encoding('€'.ord)).to eq [:codepage, 16]
      expect(obj.find_encoding('あ'.ord)).to be_nil
      expect(obj.find_encoding('気'.ord)).to be_nil
      expect(obj.find_encoding('寫'.ord)).to be_nil
      expect(obj.find_encoding('한'.ord)).to be_nil
      expect(obj.find_encoding('观'.ord)).to be_nil
    end

    it 'finds encodings with :no_cjk option' do
      expect(obj.find_encoding('A'.ord, no_cjk: true)).to be_nil
      expect(obj.find_encoding('♠'.ord, no_cjk: true)).to eq [:codepage, 1]
      expect(obj.find_encoding('₧'.ord, no_cjk: true)).to eq [:codepage, 0]
      expect(obj.find_encoding('Д'.ord, no_cjk: true)).to eq [:codepage, 17]
      expect(obj.find_encoding('₩'.ord, no_cjk: true)).to eq [:charset, 13]
      expect(obj.find_encoding('¥'.ord, no_cjk: true)).to eq [:codepage, 0]
      expect(obj.find_encoding('€'.ord, no_cjk: true)).to eq [:codepage, 16]
      expect(obj.find_encoding('あ'.ord, no_cjk: true)).to be_nil
      expect(obj.find_encoding('気'.ord, no_cjk: true)).to be_nil
      expect(obj.find_encoding('寫'.ord, no_cjk: true)).to be_nil
      expect(obj.find_encoding('한'.ord, no_cjk: true)).to be_nil
      expect(obj.find_encoding('观'.ord, no_cjk: true)).to be_nil
    end

    context 'with ja' do
      let(:cjk) { :ja }

      it 'finds encodings' do
        expect(obj.codepages.keys).to eq [0, 1, 2, 3, 4, 5, 16, 17, 18, 19]
        expect(obj.codepages.values.map(&:key)).to eq %w[cp437 katakana cp850 cp860 cp863 cp865 cp1252 cp866 cp852 cp858]
        expect(obj.charsets.keys).to eq (0..17).to_a
        expect(obj.charsets.values.map(&:key)).to eq (0..17).to_a
        expect(obj.cjk_encoding).to be_a ::Thermal::Db::CjkEncoding
        expect(obj.cjk_encoding.instance_variable_get(:@ruby)).to eq 'Shift_JIS'

        expect(obj.find_encoding('A'.ord)).to be_nil
        expect(obj.find_encoding('♠'.ord)).to eq [:codepage, 1]
        expect(obj.find_encoding('₧'.ord)).to eq [:codepage, 0]
        expect(obj.find_encoding('Д'.ord)).to eq [:codepage, 17]
        expect(obj.find_encoding('₩'.ord)).to eq [:charset, 13]
        expect(obj.find_encoding('¥'.ord)).to eq [:codepage, 0]
        expect(obj.find_encoding('€'.ord)).to eq [:codepage, 16]
        expect(obj.find_encoding('あ'.ord)).to eq [:cjk, true]
        expect(obj.find_encoding('気'.ord)).to eq [:cjk, true]
        expect(obj.find_encoding('寫'.ord)).to eq [:cjk, true]
        expect(obj.find_encoding('한'.ord)).to be_nil
        expect(obj.find_encoding('观'.ord)).to be_nil
      end

      it 'finds encodings with :no_cjk option' do
        expect(obj.find_encoding('A'.ord, no_cjk: true)).to be_nil
        expect(obj.find_encoding('♠'.ord, no_cjk: true)).to eq [:codepage, 1]
        expect(obj.find_encoding('₧'.ord, no_cjk: true)).to eq [:codepage, 0]
        expect(obj.find_encoding('Д'.ord, no_cjk: true)).to eq [:codepage, 17]
        expect(obj.find_encoding('₩'.ord, no_cjk: true)).to eq [:charset, 13]
        expect(obj.find_encoding('¥'.ord, no_cjk: true)).to eq [:codepage, 0]
        expect(obj.find_encoding('€'.ord, no_cjk: true)).to eq [:codepage, 16]
        expect(obj.find_encoding('あ'.ord, no_cjk: true)).to be_nil
        expect(obj.find_encoding('気'.ord, no_cjk: true)).to be_nil
        expect(obj.find_encoding('寫'.ord, no_cjk: true)).to be_nil
        expect(obj.find_encoding('한'.ord, no_cjk: true)).to be_nil
        expect(obj.find_encoding('观'.ord, no_cjk: true)).to be_nil
      end
    end
  end
end
