# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe ::Thermal::Db::Loader do
  before do
    described_class.reload
  end

  describe '.device' do
    it 'when exists' do
      obj = described_class.device('epson_tm_t88ii')
      expect(obj).to be_a ::Thermal::Db::Device
      expect(described_class.instance_variable_get(:@cache)['devices']).to eq('epson_tm_t88ii' => obj)
    end

    it 'when does not exist' do
      obj = described_class.device('xxx')
      expect(obj).to be_nil
      expect(described_class.instance_variable_get(:@cache)['devices']).to eq('xxx' => nil)
    end
  end

  describe '.encoding' do
    it 'when exists' do
      obj = described_class.encoding('cp860')
      expect(obj).to be_a ::Thermal::Db::Encoding
      expect(described_class.instance_variable_get(:@cache)['encodings']).to eq('cp860' => obj)
    end

    it 'when does not exist' do
      obj = described_class.encoding('xxx')
      expect(obj).to be_nil
      expect(described_class.instance_variable_get(:@cache)['encodings']).to eq('xxx' => nil)
    end
  end

  describe '.charset' do
    it 'when exists' do
      obj = described_class.charset('4')
      expect(obj).to be_a ::Thermal::Db::Charset
      expect(described_class.instance_variable_get(:@cache)['charsets']).to eq(4 => obj)
    end

    it 'when does not exist' do
      obj = described_class.charset('100')
      expect(obj).to be_nil
      expect(described_class.instance_variable_get(:@cache)['charsets']).to eq(100 => nil)
    end
  end

  describe '.cjk_encoding' do
    it 'when exists' do
      obj = described_class.cjk_encoding('big5')
      expect(obj).to be_a ::Thermal::Db::CjkEncoding
      expect(described_class.instance_variable_get(:@cache)['cjk_encodings']).to eq('big5' => obj)
    end

    it 'when does not exist' do
      obj = described_class.cjk_encoding('en')
      expect(obj).to be_nil
      expect(described_class.instance_variable_get(:@cache)['cjk_encodings']).to eq('en' => nil)
    end
  end
end
