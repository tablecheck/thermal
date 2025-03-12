# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Thermal::EscposStar::Buffer do
  let(:obj) { described_class.new }

  describe '#write_text' do
    let(:text) do
      'Hi$ ♠ 円年月 Foo あ気₩观 Test €円$年月 ♠ €!'
    end

    let(:init) do
      [
        27, 64,    # HW init
        28, 46,    # CJK off
        28, 67, 0, # CJK off
        27, 82, 0, # Charset 0
        27, 29, 116, 128 # Special Codepage 128 - UTF-8
      ]
    end

    let(:seq) do
      init + text.bytes
    end

    it 'initializes the buffer' do
      expect(obj.to_a).to eq init
    end

    it 'encodes a string' do
      obj.write_text(text)
      # puts seq.inspect
      # puts obj.to_a.inspect
      expect(obj.to_a).to eq seq
    end

    it 'accepts random keyword args' do
      obj.write_text('Foo', foo: 'bar', baz: 'qux')
      expect(obj.to_a).to eq(init + 'Foo'.bytes)
    end
  end
end
