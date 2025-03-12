require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Thermal::Printer do

  describe "#translation" do
    it "should be empty" do
      Thermal::Printer.translate.should be {}
    end
  end

  describe "#getCode" do
    it "should return open/close tag array" do
      Thermal::Printer.getCode(:tag).should eq ['', '']
    end
  end

  describe "#startCode" do
    it "should return a printer code to start a print mode" do
      Thermal::Printer.startCode(:tag).should eq ''
    end
  end

  describe "#endCode" do
    it "should return a printer code to end a print mode" do
      Thermal::Printer.endCode(:tag).should eq ''
    end
  end

end
