# frozen_string_literal: true

module Thermal
  class WriterBase
    extend Forwardable

    ALIGNMENTS = %i[left center right].freeze

    def initialize(profile)
      @profile = profile
      @bold = false
      @underline = false
      @align = :left
    end

    def format
      self.class.format if self.class.respond_to?(:format)
    end

    def print(**_kwargs)
      yield
    end

    def text(str, feed: true, replace: nil)
      # do nothing
    end

    def hr
      # do nothing
    end

    def align(alignment = nil, &)
      alignment = alignment.downcase.to_sym if alignment.is_a?(String)
      alignment ||= :left
      raise "Invalid align #{alignment.inspect}" unless ALIGNMENTS.include?(alignment)
      write_style(align: alignment, &)
    end

    def bold(enabled = true, &) # rubocop:disable Style/OptionalBooleanParameter
      write_style(bold: !!enabled, &)
    end

    def underline(enabled = true, weight: nil, &) # rubocop:disable Style/OptionalBooleanParameter
      underline = weight || enabled
      underline = false if !underline || underline == 0
      write_style(underline: underline, &)
    end

    def feed
      # do nothing
    end

    def cut
      # do nothing
    end

    def image
      # do nothing
    end

    def qr_code
      # do nothing
    end

    def_delegators :@profile,
                   :supports?,
                   :col_width

    protected

    def hr_char(style = nil)
      # rubocop:disable Lint/DuplicateBranch
      case style
      when :bold then '▄'
      when :double then '═'
      when :underline then '_'
      when :half_lower then '▄'
      when :half_upper then '▀'
      when :full then '█'
      else '─'
      end
      # rubocop:enable Lint/DuplicateBranch
    end

    def write_style(align: nil, bold: nil, underline: nil)
      prev_align     = @align
      prev_bold      = @bold
      prev_underline = @underline
      @align     = align     unless align.nil?
      @bold      = bold      unless bold.nil?
      @underline = underline unless underline.nil?
      write_align!     unless @align     == prev_align
      write_bold!      unless @bold      == prev_bold
      write_underline! unless @underline == prev_underline
      return unless block_given?
      yield
      inner_align     = @align
      inner_bold      = @bold
      inner_underline = @underline
      @align     = prev_align
      @bold      = prev_bold
      @underline = prev_underline
      write_align!     unless @align     == inner_align
      write_bold!      unless @bold      == inner_bold
      write_underline! unless @underline == inner_underline
    end

    def write_align!
      # do nothing
    end

    def write_bold!
      # do nothing
    end

    def write_underline!
      # do nothing
    end
  end
end
