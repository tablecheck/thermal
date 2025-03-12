task :console do
  require './lib/thermal'
  require 'pry'
  require 'hirb'
  require 'logger'
  require 'benchmark'
  include Thermal
  Pry.start binding, :input => StringIO.new(".clear")
end
