# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe ::Thermal::Db::CjkEncoding do
  let(:cjk) { ::Thermal::Db.find_cjk_encoding(locale) }
  let(:encoding) { ::Thermal::Db::Data.data.dig('encodings', cjk) }
  let(:obj) { described_class.new(locale, encoding['ruby']) }

  cases = {
    ja: {
      'あ' => [130, 160],
      '한' => nil,
      '気' => [139, 67],
      '观' => nil,
      '寫' => [155, 141],
      'א' => nil
    },
    ko: {
      'あ' => [170, 162],
      '한' => [199, 209],
      '気' => nil,
      '观' => nil,
      '寫' => [222, 208],
      'א' => nil
    },
    'zh-CN': {
      'あ' => [164, 162],
      '한' => nil,
      '気' => [154, 221],
      '观' => [185, 219],
      '寫' => [140, 145],
      'א' => nil
    },
    'zh-TW': {
      'あ' => nil,
      '한' => nil,
      '気' => nil,
      '观' => nil,
      '寫' => [188, 103],
      'א' => nil
    }
  }

  cases.each do |locale, mapping|
    context locale.to_s do
      let(:locale) { locale }

      it 'does mapping' do
        mapping.each do |char, bytes|
          # puts char
          # puts bytes.inspect
          expect(obj.char(char)&.bytes).to eq bytes
          expect(obj.char?(char)).to eq !!bytes
          expect(obj.codepoint(char.ord)&.bytes).to eq bytes
          expect(obj.codepoint?(char.ord)).to eq !!bytes
        end
      end
    end
  end
end
