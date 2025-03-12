# Thermal

Thermal Printer support for Ruby.

Intended API: (needs to be further extracted)

```ruby
printer = Thermal::Printer.new(device: :espon_tm_t88v)
printer.text('Contra felicem vix deus vires habet')
printer.align_center
printer.text('Quam vellem nescire litteras!')
printer.flush
```

You can also use it as a DSL:

```ruby
class MyChit
  include Thermal::Dsl

  def initialize
    @printer = Thermal::Printer.new(device: :espon_tm_t88v)
  end

  def print
    thermal_print do
      bold do
        text('Contra felicem vix deus vires habet')
        align(:center) do
          text('Quam vellem nescire litteras!')
        end
      end
    end
  end
end
```

Gracefully degrade where a device does not support an action.

### Format Support

- Epson ESC/POS
- Star Micronics ESC/POS (UTF-8)
- Star Micronics Starprnt
- Star Micronics Stargraphic

### Not Supported (yet)

- Wire protocols such as USB, Bluetooth, etc.
  This library is meant to run on a server; it passes
  the instructions/bytes to a client (browser, iOS, etc.)
  who should send it to the end device.
- Stargraphic is very rudimentary. It needs multiple message
  buffering.

### Features

- Support for all code

### Thread-Safety

- Config loading is thread safe.
- Don't call the same printer object from multiple thread. You're gonna have a bad time.

### TODOs

Required before open-sourcing.
- [ ] Add task to import config from receiptDb
- [ ] Rename CjkEncoding to RubyEncoding, rename CharmapEncoding, CharsetEncoding, also add IconvEncoding
- [ ] Encoding classes themselves should validate missing char (move from Escpos::Buffer class)
- [ ] Iconv config generator rake task.
- [ ] Set output format for thermal_print (default, base64, bytes, etc.)
- [ ] Params for escpos: :codepages, escpos: charsets
- [ ] Copy in Escpos and EscposImage gems
- [ ] Param pass-thru to EscposImage
- [ ] Configurability of tmp path -- specific to stargraphic (?)
- [ ] Write Readme
- [ ] DslMixin should include protocol (?), ipp_uri (?)
- [ ] Specs for all classes, including base.

Nice to haves:
- [ ] font support. col_width should be dynamic in the printer (currently depends on font 0)
- [ ] Copy "Available methods" from https://github.com/escpos/escpos-php
- [ ] Add HTML command in addition to text. Should be done as an AST (HtmlAst) like [[:text, 'ddd'], [:underline, 2, [[:text, 'foo']]]]
- [ ] Optional HTML image support
- [ ] Copy TestReport
- [ ] Stargraphic needs much better buffer support, including line break splitting + multiple buffers.
- [ ] Allow pass-in of codepage object.
- [ ] Allow pass-in of charset object.
- [ ] Indian ISCII encoding for Escpos (separate gem?).

### Thanks

This gem draws inspiration from the following libraries:
- https://github.com/escpos/escpos-php

#### References

- https://github.com/escpos/escpos-php
- https://github.com/receipt-print-hq/escpos-printer-db
- https://github.com/NielsLeenheer/EscPosEncoder/blob/master/src/esc-pos-encoder.js
- https://reference.epson-biz.com/modules/ref_charcode_ja/index.php?content_id=10
- https://reference.epson-biz.com/modules/ref_charcode_ja/index.php?content_id=117
- https://reference.epson-biz.com/modules/ref_charcode_ja/index.php?content_id=118
- https://reference.epson-biz.com/modules/ref_charcode_ja/index.php?content_id=119
- https://www.sparkag.com.br/wp-content/uploads/2016/06/ESC_POS-AK912-English-Command-Specifications-V1.4.pdf
- https://en.wikipedia.org/wiki/Code_page
- https://www.wikiwand.com/en/Code_page_1098
- Unicode to ISCII: https://github.com/irshadbhat/litcm/blob/master/litcm/wxILP.py
