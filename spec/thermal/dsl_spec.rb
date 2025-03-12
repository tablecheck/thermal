# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe ::Thermal::Dsl do
  let(:dummy_base) do
    Class.new do
      include ::Thermal::Dsl

      def printer
        @printer ||= ::Thermal::Printer.new(:epson_tm_t88iv)
      end

      def data
        thermal_print(output: :byte_array) { dsl }
      end

      def dsl
        # override in test
      end
    end
  end

  describe '#thermal_print' do
    let(:output) { dummy.new.data }

    context 'simple' do
      let(:dummy) do
        Class.new(dummy_base) do
          def dsl
            text 'Test'
            hr
          end
        end
      end

      let(:exp) do
        [
          27, 64, # HW init
          84, 101, 115, 116, # text: "Test"
          10, # text line feed
          [196] * 42, # HR
          10, # HR line feed
          [10] * 5, # Line feed from print
          29, 86, 0 # Paper cut
        ].flatten
      end

      it do
        expect(output).to eq exp
      end
    end

    context 'complex nesting' do
      let(:dummy) do
        Class.new(dummy_base) do
          def dsl
            align(:center) do
              text "Test\r"
              hr
              bold do
                text 'Foo'
                underline do
                  text 'Baz'
                end
                align('Right') do
                  text 'Qux'
                end
                hr(:bold)
              end
            end
            hr
          end
        end
      end

      let(:exp) do
        [
          27, 64, # HW init
          27, 97, 1, # align center
          84, 101, 115, 116, # text: "Test"
          10, # text line feed
          [196] * 42, # HR
          10, # HR line feed
          27, 69, 1, # bold on
          70, 111, 111, # text: "Foo"
          10, # text line feed
          27, 45, 1, # underline on
          66, 97, 122, # text: "Baz"
          10, # text line feed
          27, 45, 0, # underline off
          27, 97, 2, # align right
          81, 117, 120, # text: "Qux"
          10, # text line feed
          27, 97, 1, # align center (end inner align left)
          [220] * 42, # HR bold
          10, # HR line feed
          27, 69, 0, # bold off
          27, 97, 0, # align left (end align center)
          [196] * 42, # HR
          10, # HR line feed
          [10] * 5, # Line feed from print
          29, 86, 0 # Paper cut
        ].flatten
      end

      it do
        expect(output).to eq exp
      end
    end

    context 'complex nesting with flat overrides' do
      let(:dummy) do
        Class.new(dummy_base) do
          def dsl
            align(:center) do
              text 'Test'
              align(:center)
              hr
              bold do
                text 'Foo'
                underline do
                  bold(false)
                  align(:right)
                  text "B\raz"
                end
                text 'Test'
                bold
                align(:left) do
                  bold(false)
                  text 'Qux'
                end
                align(:right)
                text 'Foo'
                hr(:bold)
              end
            end
            hr
          end
        end
      end

      let(:exp) do
        [
          27, 64, # HW init
          27, 97, 1, # align center
          84, 101, 115, 116, # text: "Test"
          10, # text line feed
          [196] * 42, # HR
          10, # HR line feed
          27, 69, 1, # bold on
          70, 111, 111, # text: "Foo"
          10, # text line feed
          27, 45, 1, # underline on
          27, 69, 0, # bold off (inline)
          27, 97, 2, # align right (inline)
          66, 97, 122, # text: "Baz"
          10, # text line feed
          27, 97, 1, # align center (revert)
          27, 69, 1, # bold on (revert)
          27, 45, 0, # underline off
          84, 101, 115, 116, # text: "Test"
          10, # text line feed
          27, 97, 0, # align left (inline)
          27, 69, 0, # bold off (inline)
          81, 117, 120, # text: "Qux"
          10, # text line feed
          27, 97, 1, # align center (revert)
          27, 69, 1, # bold on (revert)
          27, 97, 2, # align right
          70, 111, 111, # text: "Foo"
          10, # text line feed
          [220] * 42, # HR bold
          10, # HR line feed
          27, 97, 1, # align center (end bold block)
          27, 69, 0, # bold off (end bold block)
          27, 97, 0, # align left (end align block)
          [196] * 42, # HR
          10, # HR line feed
          [10] * 5, # Line feed from print
          29, 86, 0 # Paper cut
        ].flatten
      end

      it do
        # puts exp.inspect
        # puts output.inspect
        expect(output).to eq exp
      end
    end

    context 'CJK' do
      let(:dummy) do
        Class.new(dummy_base) do
          def printer
            @printer ||= ::Thermal::Printer.new(:epson_tm_t88iv, cjk_encoding: 'shift_jis')
          end

          def dsl
            align(:center) do
              text('予約')
              text('Chez Louis')
              hr
            end
            text("顧客: Test 様")
            hr
          end
        end
      end

      let(:exp) do
        [
          27, 64, # HW init
          28, 46, # CJK off
          27, 97, 1, # align center
          28, 67, 1, # Shift-JIS on
          151, 92, 150, 241, 10, # text kanji: yoyaku
          67, 104, 101, 122, 32, 76, 111, 117, 105, 115, 10, # Chez Louis
          28, 67, 0, # Shift-JIS off
          [196] * 42, # HR
          10, # HR line feed
          27, 97, 0, # align left
          28, 67, 1, # Shift-JIS on
          140, 218, 139, 113, 58, 32, # text kanji: kokyaku
          84, 101, 115, 116, 32, # text: "Test"
          151, 108, 10, # text kanji: sama
          28, 67, 0, # Shift-JIS off
          [196] * 42, # HR
          10, # HR line feed
          [10] * 5, # Line feed from print
          29, 86, 0 # Paper cut
        ].flatten
      end

      it do
        # puts exp.inspect
        # puts output.inspect
        expect(output).to eq exp
      end
    end
  end
end
