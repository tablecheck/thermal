# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe ::Thermal::Escpos::Buffer do
  let(:cjk) { nil }
  let(:profile) { ::Thermal::Profile.new(device, cjk_encoding: cjk) }
  let(:obj) { described_class.new(profile) }
  let(:init) do
    [27, 64] # HW init
  end
  let(:cjk_init) do
    [
      27, 64, # HW init
      28, 46  # CJK off
    ]
  end

  context 'epson_tm_t88v' do
    let(:device) { :epson_tm_t88v }

    let(:seq) do
      [
        27, 64, # HW init
        72,  # H
        105, # i
        36,  # $
        32,  # space
        27, 116, 1, # Codepage 1 - Katakana
        232, # ♠
        32,  # space
        241, # 円
        242, # 年
        248, # 〒
        243, # 月
        32,  # space
        70,  # F
        111, # o
        111, # o
        32,  # space
        32,  # space - skip invalid あ
        32,  # space - skip invalid 気
        27, 82, 13, # Charset 13 - Korean
        92,  # ₩
        32,  # space - skip invalid 观
        32,  # space
        84,  # T
        101, # e
        115, # s
        116, # t
        32,  # space
        27, 116, 16, # Codepage 16 - Euro
        128, # €
        27, 116, 1, # Codepage 1 - Katakana
        241, # 円
        27, 82, 0, # Charset 0
        36,  # $
        242, # 年
        243, # 月
        32,  # space
        232, # ♠
        32,  # space
        27, 116, 16, # Codepage 16 - Euro
        128, # €
        33   # !
      ]
    end

    it 'initializes the buffer' do
      expect(obj.to_a).to eq init
    end

    it 'encodes a string' do
      obj.write_text("Hi$ ♠ 円年〒月 Foo あ気₩观 Test €円$年月 ♠ €!")
      # puts seq.inspect
      # puts obj.to_a.inspect
      expect(obj.to_a).to eq seq
    end

    context 'with ja' do
      let(:cjk) { :ja }

      let(:seq) do
        [
          27, 64, # HW init
          28, 46, # CJK off
          72,  # H
          105, # i
          32,  # space
          27, 116, 1, # Codepage 1 - Katakana
          232, # ♠
          32,  # space
          28, 67, 1, # Shift-JIS on
          137, 126,  # 円 (Shift-JIS)
          148, 78,   # 年 (Shift-JIS)
          129, 167,  # 〒 (Shift-JIS)
          140, 142,  # 月 (Shift-JIS)
          32,  # space
          70,  # F
          111, # o
          111, # o
          32,  # space
          130, 160,   # あ (Shift-JIS)
          139, 67,    # 気 (Shift-JIS)
          27, 82, 13, # Charset 13 - Korean
          92,  # ₩
          32,  # space - skip invalid 观
          32,  # space
          84,  # T
          101, # e
          115, # s
          116, # t
          32,  # space
          137, 126,  # 円 (Shift-JIS)
          27, 82, 0, # Charset 0
          36,        # $
          148, 78,   # 年 (Shift-JIS)
          140, 142,  # 月 (Shift-JIS)
          32,        # space
          28, 67, 0, # Shift-JIS off
          232, # ♠ (Katakana)
          32,  # space
          27, 116, 16, # Codepage 16 - Euro
          128, # €
          33   # !
        ]
      end

      it 'initializes the buffer' do
        expect(obj.to_a).to eq cjk_init
      end

      it 'encodes a string' do
        obj.write_text("Hi ♠ 円年〒月 Foo あ気₩观 Test 円$年月 ♠ €!")
        # puts seq.inspect
        # puts obj.to_a.inspect
        expect(obj.to_a).to eq seq
      end

      context 'no_cjk' do
        let(:seq) do
          [
            27, 64, # HW init
            28, 46, # CJK off
            72,  # H
            105, # i
            32,  # space
            27, 116, 1, # Codepage 1 - Katakana
            232, # ♠
            32,  # space
            241, # 円
            242, # 年
            248, # 〒
            243, # 月
            32,  # space
            70,  # F
            111, # o
            111, # o
            32,  # space
            32, 32, # blank chars
            27, 82, 13, # Charset 13 - Korean
            92,  # ₩
            32,  # space - skip invalid 观
            32,  # space
            84,  # T
            101, # e
            115, # s
            116, # t
            32,  # space
            241, # 円
            27, 82, 0, # Charset 0
            36,        # $
            242, # 年
            243, # 月
            32,        # space
            232, # ♠ (Katakana)
            32,  # space
            27, 116, 16, # Codepage 16 - Euro
            128, # €
            33   # !
          ]
        end

        it 'encodes a string' do
          obj.write_text("Hi ♠ 円年〒月 Foo あ気₩观 Test 円$年月 ♠ €!", no_cjk: true)
          # puts seq.inspect
          # puts obj.to_a.inspect
          expect(obj.to_a).to eq seq
        end
      end
    end

    context 'with ko' do
      let(:cjk) { :ko }

      let(:seq) do
        [
          27, 64, # HW init
          28, 46, # CJK off
          72,     # H
          160,    # á
          28, 38, # CJK on
          176, 168, # 감 (EUC-KR)
          187, 231, # 사 (EUC-KR)
          192, 167, # 위 (EUC-KR)
          191, 248, # 원 (EUC-KR)
          192, 186, # 은 (EUC-KR)
          32,  # space
          72,  # H
          105, # i
          32,  # space
          229, 247, # 円
          210, 180, # 年
          28, 46, # CJK off
          27, 116, 1, # Codepage 1 - Kanakana
          248, # 〒
          233, # ♠ (Katakana)
          28, 38, # CJK on
          234, 197, # 月
          32,  # space - skip invalid 这
          227, 192, # 是
          191, 248, # 원
          192, 229, # 장
          192, 199, # 의
          27, 82, 13, # Charset 13 - Korean
          92,  # ₩
          32,  # space - skip invalid 观
          32,  # space
          84,  # T
          101, # e
          115, # s
          116, # t
          28, 46, # CJK off
          177, # ｱ
          32,  # space
          28, 38, # CJK on
          210, 180, # 年
          27, 82, 0, # Charset 0
          36,  # $
          210, 180, # 年
          32,  # space - skip invalid 这
          234, 197, # 月
          32,  # space
          28, 46, # CJK off
          232  # ♠ (Katakana)
        ]
      end

      it 'initializes the buffer' do
        expect(obj.to_a).to eq cjk_init
      end

      it 'encodes a string' do
        obj.write_text("Há감사위원은 Hi 円年〒♥月这是원장의₩观 Testｱ 年$年这月 ♠")
        # puts seq.inspect
        # puts obj.to_a.inspect
        expect(obj.to_a).to eq seq
      end

      context 'no_cjk' do
        let(:seq) do
          [
            27, 64, # HW init
            28, 46, # CJK off
            72,  # H
            160, # á
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # space
            72,  # H
            105, # i
            32,  # space
            27, 116, 1, # Codepage 1 - Katakana
            241, # 円 (Katakana)
            242, # 年 (Katakana)
            248, # 〒 (Katakana)
            233, # ♠ (Katakana)
            243, # 月 (Katakana)
            32,  # space - skip invalid 这
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # skip
            27, 82, 13, # Charset 13 - Korean
            92,  # ₩
            32,  # space - skip invalid 观
            32,  # space
            84,  # T
            101, # e
            115, # s
            116, # t
            177, # ｱ
            32,  # space
            242, # 年 (Katakana)
            27, 82, 0, # Charset 0
            36,  # $
            242, # 年 (Katakana)
            32,  # space - skip invalid 这
            243, # 月 (Katakana)
            32,  # space
            232  # ♠ (Katakana)
          ]
        end

        it 'encodes a string' do
          obj.write_text("Há감사위원은 Hi 円年〒♥月这是원장의₩观 Testｱ 年$年这月 ♠", no_cjk: true)
          # puts seq.inspect
          # puts obj.to_a.inspect
          expect(obj.to_a).to eq seq
        end
      end
    end

    context 'with zh-CN' do
      let(:cjk) { :'zh-CN' }

      let(:seq) do
        [
          27, 64,   # HW init
          28, 46,   # CJK off
          28, 38,   # CJK on
          213, 226, # 这 (GB)
          202, 199, # 是 (GB)
          202, 178, # 什 (GB)
          195, 180, # 么 (GB)
          163, 191, # ？ (GB)
          32,  # space
          72,  # H
          105, # i
          32,  # space
          131, 210, # 円 (GB)
          196, 234, # 年 (GB)
          168, 147, # 〒 (GB)
          212, 194, # 月 (GB)
          32,  # space
          32,  # space - skip invalid 한
          27, 82, 13, # Charset 13 - Korean
          92,  # ₩
          185, 219,  # 观 (GB)
          32,  # space
          84,  # T
          101, # e
          115, # s
          116, # t
          28, 46,     # CJK off
          27, 116, 1, # Codepage 1 - Kanakana
          177, # ｱ
          32,  # space
          28, 38,    # CJK on
          196, 234,  # 年 (GB)
          27, 82, 0, # Charset 0
          36,        # $
          196, 234,  # 年 (GB)
          213, 226,  # 这 (GB)
          212, 194,  # 月 (GB)
          32,        # space
          28, 46,    # CJK off
          232        # ♠ (Katakana)
        ]
      end

      it 'initializes the buffer' do
        expect(obj.to_a).to eq cjk_init
      end

      it 'encodes a string' do
        obj.write_text("这是什么？ Hi 円年〒月 한₩观 Testｱ 年$年这月 ♠")
        # puts seq.inspect
        # puts obj.to_a.inspect
        expect(obj.to_a).to eq seq
      end

      context 'no_cjk' do
        let(:seq) do
          [
            27, 64,   # HW init
            28, 46,   # CJK off
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # space
            72,  # H
            105, # i
            32,  # space
            27, 116, 1, # Codepage 1 - Katakana
            241, # 円 (Katakana)
            242, # 年 (Katakana)
            248, # 〒 (Katakana)
            243, # 月 (Katakana)
            32,  # space
            32,  # space - skip invalid 한
            27, 82, 13, # Charset 13 - Korean
            92,  # ₩
            32,  # skip
            32,  # space
            84,  # T
            101, # e
            115, # s
            116, # t
            177, # ｱ
            32,  # space
            242, # 年 (Katakana)
            27, 82, 0, # Charset 0
            36,  # $
            242, # 年 (Katakana)
            32,  # skip
            243, # 月 (Katakana)
            32,  # space
            232  # ♠ (Katakana)
          ]
        end

        it 'encodes a string' do
          obj.write_text("这是什么？ Hi 円年〒月 한₩观 Testｱ 年$年这月 ♠", no_cjk: true)
          # puts seq.inspect
          # puts obj.to_a.inspect
          expect(obj.to_a).to eq seq
        end
      end
    end

    context 'with zh-TW' do
      let(:cjk) { :'zh-TW' }

      let(:seq) do
        [
          27, 64, # HW init
          28, 46, # CJK off
          72,  # H
          105, # i
          36,  # $
          32,  # space
          28, 38,   # CJK on
          193, 99,  # 繁 (Big5)
          197, 233, # 體 (Big5)
          166, 114, # 字 (Big5)
          32,  # space
          28, 46,     # CJK off
          27, 116, 1, # Codepage 1 - Kanakana
          241, # 円 (Katakana)
          28, 38,   # CJK on
          166, 126, # 年 (Big5)
          162, 69,  # 〒 (Big5)
          164, 235, # 月 (Big5)
          32,  # space - skip invalid 这
          172, 79, # 是 (Big5)
          32,  # space - skip invalid 원
          32,  # space - skip invalid 장
          32,  # space - skip invalid 의
          27, 82, 13,
          92,  # ₩
          32,  # space - skip invalid 观
          32,  # space
          84,  # T
          101, # e
          115, # s
          116, # t
          28, 46, # CJK off
          177, # ｱ (Katakana)
          32,  # space
          28, 38,    # CJK on
          166, 126,  # 年 (Big5)
          27, 82, 0, # Codepage 0
          36,  # $
          166, 126, # 年 (Big5)
          32,  # space - skip invalid 这
          28, 46, # CJK off
          232  # ♠ (Katakana)
        ]
      end

      it 'initializes the buffer' do
        expect(obj.to_a).to eq cjk_init
      end

      it 'encodes a string' do
        obj.write_text("Hi$ 繁體字 円年〒月这是원장의₩观 Testｱ 年$年这♠")
        # puts seq.inspect
        # puts obj.to_a.inspect
        expect(obj.to_a).to eq seq
      end

      context 'no_cjk' do

        let(:seq) do
          [
            27, 64, # HW init
            28, 46, # CJK off
            72,  # H
            105, # i
            36,  # $
            32,  # space
            32,  # skip
            32,  # skip
            32,  # skip
            32,  # space
            27, 116, 1, # Codepage 1 - Kanakana
            241, # 円 (Katakana)
            242, # 年 (Katakana)
            248, # 〒 (Katakana)
            243, # 月 (Katakana)
            32,  # space - skip invalid 这
            32,  # skip
            32,  # space - skip invalid 원
            32,  # space - skip invalid 장
            32,  # space - skip invalid 의
            27, 82, 13,
            92,  # ₩
            32,  # space - skip invalid 观
            32,  # space
            84,  # T
            101, # e
            115, # s
            116, # t
            177, # ｱ (Katakana)
            32,  # space
            242, # 年 (Katakana)
            27, 82, 0, # Codepage 0
            36,  # $
            242, # 年 (Katakana)
            32,  # space - skip invalid 这
            232  # ♠ (Katakana)
          ]
        end

        it 'encodes a string' do
          obj.write_text("Hi$ 繁體字 円年〒月这是원장의₩观 Testｱ 年$年这♠", no_cjk: true)
          # puts seq.inspect
          # puts obj.to_a.inspect
          expect(obj.to_a).to eq seq
        end
      end
    end
  end
end
