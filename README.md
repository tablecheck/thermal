# Thermal

Thermal printer support for Ruby. Used to print receipts, chits, tickets, labels, etc.

### Features

- Simple and opinionated API. **It just works™**
- Generates **rich text, image, and QR codes** for thermal printers.
- Supports a broad range of **makers and models** (Epson, Star Micronics, Brother, PBM, Zijiang, etc.)
- Automatic **multi-lingual** codepage support, including support for **CJK extended character sets**.
- **Simple DSL** for rich text output formatting.
- **Graceful degradation** of features based on printer capabilities.

### Optional Features

- **HTML-to-text support**
  - Requires [nokogiri](https://nokogiri.org/) gem.
- **QR code generation**
  - Requires [rqrcode](https://github.com/whomwah/rqrcode) gem.
- Support for **Stargraphic pixel-only printer** with system-side font rasterization.
  - See requirements below.

### Supported Output Formats

- Epson ESC/POS
  - Industry standard used by most thermal printers
- Star Micronics-specific formats
  - Star Micronics Extended ESC/POS (UTF-8)
  - Starprnt
  - Stargraphic

### Non-Features & Limitations

- **No support for wire protocols** such as USB, Bluetooth, etc. This gem is intended
  to run on a server; it only generates  the instructions/bytes to be sent to the client
- (browser, iOS, etc.) which should then send it to the end device.
  - **PR welcome** if someone wants to add USB/Bluetooth support.
- **Pixel-only printer support (Stargraphic) is rudimentary and slow**, because
  it uses system-side font rendering ([Pango](https://www.pango.org/)) to generate
  the image data.
  - **PR welcome** to use a different approach and/or make it faster.
- Table formatting support not yet added. **PR welcome**.
- Indian ISCII encoding for Escpos is not yet supported. **PR welcome**.

## How to Use

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'thermal'
```

### Formatting your Output

#### Procedural code

Intended API: (needs to be further extracted)

```ruby
printer = Thermal::Printer.new(device: :espon_tm_t88v)
printer.text('Contra felicem vix deus vires habet')
printer.align_center
printer.text('Quam vellem nescire litteras!')
printer.flush # todo: #print!?
```

#### DSL

You can also use it as a DSL:

```ruby
# TODO: Example text should look like an actual receipt
class MyChitPrinter
  include Thermal::Dsl

  def initialize
    @printer = Thermal::Printer.new(device: :espon_tm_t88v)
  end

  def print
    thermal_print do # TODO: does this flush automatically?
      bold do
        text('Contra felicem vix deus vires habet')
        align(:center) do
          text('Quam vellem nescire litteras!')
        end
        # html do
        #
        # end
        # html('<b>foo</b>')
      end
    end
  end
end
```

#### HTML Conversion

```ruby
# TODO: float/tables?
# h1
# h2
# h3
# 
```


### Integrating in an app

- Add details of how to implement a thermal printer config.

### Thread-Safety

- Config loading is thread safe.
- Don't call the same `Thermal::Printer` object from multiple threads.
  You're gonna have a bad time.

### TODOs

Required before releasing.
- [ ] Yaml safe load
- [ ] Add task to import config from escpos-printer-db
- [ ] Rename CjkEncoding to RubyEncoding, rename CharmapEncoding, CharsetEncoding, also add IconvEncoding
- [ ] Encoding classes themselves should validate missing char (move from Escpos::Buffer class)
- [ ] Iconv config generator rake task.
- [ ] Set output format for thermal_print (default, base64, bytes, etc.)
- [ ] Params for escpos: :codepages, escpos: charsets
- [ ] Copy in Escpos and EscposImage gems
- [ ] Param pass-thru to EscposImage
- [ ] Configurability of tmp path -- specific to stargraphic (?) -- Should use Tempfile
- [ ] Write Readme
- [ ] DslMixin should include protocol (?), ipp_uri (?) -- why??
- [ ] Specs for all classes, including base.
- [ ] Remove UNF with and replace with ruby unicode?
- [ ] StarGraphic needs multiple message buffering. ???
- [ ] Add QR to DSL

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

# Contributing

To add support for additional Thermal printers.
- escpos-printer-db
- Add new code in `lib/thermal/printer/escpos.rb`
- Add new code in `lib/thermal/printer/starprnt.rb`

# Acknowledgements

### Maintainers

HTMLDiff is maintained and battle-tested by the team at [TableCheck](https://www.tablecheck.com/en/join/)
based in Tokyo, Japan. We use Thermal to help our restaurant users print
chits, receipts, and QR code printouts to help
visualize the edit history of their customer and reservation data. If you're seeking
your next career adventure, [we're hiring](https://careers.tablecheck.com/)!

### Data Sources

This gem relies on the community-maintained
[escpos-printer-db](https://github.com/receipt-print-hq/escpos-printer-db)
to provide a comprehensive list of thermal printers.

### Special Thanks

This gem draws inspiration from the following libraries.
Thank you to the authors for their hard work.
- [escpos-php](https://github.com/escpos/escpos-php)
- [escpos-printer-db](https://github.com/receipt-print-hq/escpos-printer-db)
- [EscPosEncoder JS](https://github.com/NielsLeenheer/EscPosEncoder/blob/master/src/esc-pos-encoder.js)

### Copyright Attribution

The vendor manuals in the `doc/vendor` directory are the property of their respective owners.
They are included here for references purposes only under the fair use doctrine.

### License

This gem is released under the MIT License. Please see the [LICENSE](LICENSE) file for details.
