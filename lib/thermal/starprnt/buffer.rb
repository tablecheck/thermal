# frozen_string_literal: true

module Thermal
module Starprnt
  class Buffer
    COMMANDS = %i[ printRawText
                   printRasterReceipt
                   printImage
                   printBase64Image
                   print ].freeze

    # print is a special command that takes an an array of subcommands
    def print(array)
      commands.push(print: []) if last_command != :print
      commands.last[:print] += Array.wrap(array)
    end

    # other commands take a single object
    (COMMANDS - [:print]).each do |cmd|
      define_method(::Thermal::Util.underscore(cmd)) do |object|
        commands.push(cmd => object)
      end
    end

    def flush
      tmp = commands
      @commands = []
      tmp
    end

    def to_a
      commands.deep_dup
    end

    protected

    def commands
      @commands ||= []
    end

    def last_command
      commands.last&.keys&.first
    end
  end
end
end
