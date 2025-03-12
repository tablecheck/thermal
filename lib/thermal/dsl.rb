# frozen_string_literal: true

module Thermal
  module Dsl
    def self.included(base)
      base.class_eval do

        def thermal_print(**kwargs, &block)
          printer.print(**kwargs, &block)
        end

        private

        ::Thermal::Printer::PRINT_METHODS.each do |meth|
          define_method(meth) do |*args, **kwargs, &block|
            raise 'Must define #printer method or set @printer variable' unless printer
            printer.send(meth, *args, **kwargs, &block)
          end
          private(meth)
        end

        def printer
          @printer
        end
      end
    end
  end
end
