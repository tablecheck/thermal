# frozen_string_literal: true

module Thermal
module Stargraphic
  # TODO: image buffer
  # TODO: page limit
  class Writer < ::Thermal::WriterBase
    DOT_WIDTH = 576
    LINE_HEIGHT = 34
    PAGE_LENGTH = 32_000
    MAX_BYTES = 500_000 # Star API allows 500KB max

    def initialize(profile)
      @width = DOT_WIDTH
      @align = :left
      super
    end

    def self.format
      'stargraphic'
    end

    def print(flush: true)
      seq_init_raster_mode
      seq_enter_raster_mode
      seq_set_page_length
      super
      feed(5)
      cut
      finalize(flush: flush)
    end

    def text(str, feed: true, replace: nil, **_kwargs)
      str = ::Thermal::Util.normalize_utf8(str, replace: replace)
      str = "#{str}\n" if feed
      append_text(str) if str
    end

    def hr(style = nil, width: col_width) # rubocop:disable Lint/UnusedMethodArgument
      append_image(hr_image(style))
      # append_raw(hr_seq(style))
    end

    def bold
      @bold = true
      yield
      @bold = false
    end

    def underline(weight: nil) # rubocop:disable Lint/UnusedMethodArgument
      @underline = true
      yield
      @underline = false
    end

    def feed(lines = 1)
      feed_rows(lines * LINE_HEIGHT)
    end

    def image(path)
      width, height = ::MiniMagick::Image.open(path).dimensions
      output, = Open3.capture3("convert #{path} -depth 1 R:-", binmode: true)
      output = output.chomp
      append_image([width, height, output])
    end

    def qr_code(url)
      append_image(qr_code_image(url))
    end

    def cut
      seq_set_em_mode
      seq_exec_em
    end

    protected

    def commands
      @commands ||= []
    end

    def buffer
      @buffer ||= ::Thermal::Stargraphic::CappedByteBuffer.new(MAX_BYTES)
    end

    def finalize(flush: true, output: nil)
      rasterize_text
      write_commands_to_buffer
      @commands = []
      if output == :byte_array
        [flush ? buffer.flush : buffer.to_a]
      else
        [flush ? buffer.flush_base64 : buffer.to_base64]
      end
    end

    def rasterize_text
      commands.each_index do |i|
        if commands[i][0] == :text
          data = commands[i][1]
          @commands[i] = [:image, text_image(data[0], align: data[1])]
        end
      end
    end

    def write_commands_to_buffer
      commands.each do |type, obj|
        case type
        when :raw   then write(obj)
        when :image then write_image(obj)
        else raise "Cannot write type #{type.inspect}"
        end
      end
    end

    def write(obj)
      buffer << obj
    end

    def write_image(obj)
      width, _, data = obj
      raise "Width #{width}px must be a multiple of 8" unless width % 8 == 0
      raise "Width #{width}px cannot be greater than #{@width}px" if width > @width

      byte_width = width / 8
      row_cmd = [98, byte_width, 0]
      data.each_chunk(byte_width) do |row|
        buffer << row_cmd
        buffer << row
      end
    end

    # control chars:
    # \e{ - converts to <
    # \e} - converts to >
    def append_text(str, font_size: 21, spacing: -2)
      str = str
            .gsub('&', '&amp;')
            .gsub('\\', '&#92;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('&', '&amp;') # do a second-pass on & char
            .gsub("\e{", '<')
            .gsub("\e}", '>')

      str = "<i>#{str}</i>" if @italic
      str = "<b>#{str}</b>" if @bold
      str = "<u>#{str}</u>" if @underline
      str = "<span size='#{(font_size * 1024).to_i}' letter_spacing='#{(spacing * 1024).to_i}'>#{str}</span>"
      str = str.encode_utf8('')

      if commands[-1] && commands[-1][0] == :text && commands[-1][1][1] == @align # align match
        commands[-1][1][0] << str
      else
        commands << [:text, [str, @align]]
      end
    end

    def append_image(obj)
      obj[2] = (+obj[2]).force_encoding('UTF-8')
      if commands[-1] && commands[-1][0] == :image && commands[-1][1][0] == obj[0] # width match
        commands[-1][1][1] += obj[1] # add height
        commands[-1][1][2] << obj[2] # append data
      else
        commands << [:image, obj]
      end
    end

    def append_raw(obj)
      commands << [:raw, obj]
    end

    def seq_set_page_length(length = 32_000)
      append_raw([27, 42, 114, 80] + length.to_s.each_char.map(&:ord) + [0])
    end

    def seq_init_raster_mode
      append_raw [27, 42, 114, 82]
    end

    def seq_enter_raster_mode
      append_raw [27, 42, 114, 65]
    end

    def seq_set_em_mode(cut = true) # rubocop:disable Style/OptionalBooleanParameter
      append_raw [27, 42, 114, 101, cut ? 13 : 0, 0]
    end

    def seq_exec_em
      append_raw [27, 12, 25]
    end

    def font
      self.class.font
    end

    class << self
      # Persists font as singleton
      def font
        @font ||= begin
          if OS.windows?
            'Sans'
          else
            font_list = begin
              `fc-list`
            rescue StandardError
              ''
            end
            case font_list
            when /NotoSans/ then 'NotoSans'
            else 'Sans'
            end
          end
        end
      end
    end

    def text_image(markup, width: @width, align: :left, font: 'Sans', delete: true)
      tmp_path = ::Thermal.tmp_path("#{SecureRandom.uuid}.png")

      begin
        ::MiniMagick::Tool::Convert.new do |i|
          i << '+antialias'
          i << '+dither'
          i.size width
          i.font font
          # replace next line with align when released
          i.gravity :center if align == :center
          # after this is released https://github.com/ImageMagick/ImageMagick6/commit/b82aa924
          # i.define "pango:align=#{align}"
          i.pango markup
          i.threshold '30%'
          i.depth 1
          i.negate
          i << tmp_path
        end
      rescue StandardError => e
        Bugsnag.notify(e) do |r|
          r.add_metadata('data',
                         text: markup,
                         width: width,
                         align: align,
                         font: font)
        end
        raise e
      end

      output, = Open3.capture3("convert #{tmp_path} -depth 1 R:-", binmode: true)
      File.delete(tmp_path) if delete
      output = output.chomp
      height = (8 * output.size / width.to_f).ceil
      [width, height, output]
    end

    # TODO: assumes 8px width
    # TODO: centering is off
    def qr_code_image(url, width: @width)
      cols = width / 8
      qr_lines = ::RQRCode::QRCode.new(url).to_s(dark: 'x', light: ' ').split("\n")
      height = qr_lines.size * 8
      qr_lines = qr_lines.map { |line| line.each_char.map { |d| d == 'x' ? 255 : 0 } }
      qr_cols = qr_lines.first.size
      margin = (cols - qr_cols) / 2.0
      zero = [0]
      output = qr_lines.map { |line| (zero * margin.floor + line + zero * margin.ceil) * 8 }.flatten.pack('C*')
      [width, height, output]
    end

    def feed_rows(rows)
      append_raw(feed_rows_seq(rows))
    end

    def feed_rows_seq(rows)
      [27, 42, 114, 89] + rows.to_s.each_char.map(&:ord) + [0]
    end

    def hr_image(style = nil, width: @width)
      byte_width = width / 8
      pixels = hr_pixels(style)
      output = +''
      (0...LINE_HEIGHT).each do |row|
        output << (row.in?(pixels) ? "\xFF" : "\x00") * byte_width
      end
      output.freeze
      [width, LINE_HEIGHT, output]
    end

    # More efficient
    # def hr_seq(style = nil, width: @width)
    #   byte_width = width / 8
    #   pixels = hr_pixels(style)
    #   output = []
    #   i = 0
    #   (0...LINE_HEIGHT).each do |row|
    #     if row.in?(pixels)
    #       output += feed_rows_seq(i) if i > 0
    #       output += [98, byte_width, 0] + [255] * byte_width
    #       i = 0
    #     else
    #       i += 1
    #     end
    #   end
    #   output += feed_rows_seq(i) if i > 0
    #   output
    # end

    def hr_pixels(style)
      case style
      when :bold then 11..14
      when :double then [9, 10, 15, 16]
      when :underline then 25..26
      when :half_upper then 0..12
      when :half_lower then 13..29
      when :full then 0..29
      else 12..13
      end.to_a
    end
  end
end
end
