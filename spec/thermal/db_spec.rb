# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe ::Thermal::Db do

  describe '.find_cjk_encoding' do
    it do
      expect(described_class.find_cjk_encoding(:ja)).to eq 'shift_jis'
      expect(described_class.find_cjk_encoding('ja-US')).to eq 'shift_jis'
      expect(described_class.find_cjk_encoding('ja-CN')).to eq 'shift_jis'
      expect(described_class.find_cjk_encoding(:ko)).to eq 'ksc5601'
      expect(described_class.find_cjk_encoding('ko-CN')).to eq 'ksc5601'
      expect(described_class.find_cjk_encoding(:'zh-TW')).to eq 'big5'
      expect(described_class.find_cjk_encoding('zh-CN')).to eq 'gb18030'
      expect(described_class.find_cjk_encoding(:'zh-KR')).to eq 'gb18030'
      expect(described_class.find_cjk_encoding('zh-JP')).to eq 'gb18030'
      expect(described_class.find_cjk_encoding('JP')).to eq 'shift_jis'
      expect(described_class.find_cjk_encoding('KR')).to eq 'ksc5601'
      expect(described_class.find_cjk_encoding('CN')).to eq 'gb18030'
      expect(described_class.find_cjk_encoding('SG')).to eq 'gb18030'
      expect(described_class.find_cjk_encoding(:MY)).to eq 'gb18030'
      expect(described_class.find_cjk_encoding(:TW)).to eq 'big5'
      expect(described_class.find_cjk_encoding('HK')).to eq 'big5'
      expect(described_class.find_cjk_encoding('MO')).to eq 'big5'
      expect(described_class.find_cjk_encoding('US')).to eq nil
    end
  end
end
