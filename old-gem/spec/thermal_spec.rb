require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Thermal do
  it "should have a version" do
    Thermal::VERSION.should be_a_kind_of String
  end
end
