require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe BTPR880 do

  describe "#startCode" do
    it "should translate <strong>" do
      BTPR880.startCode(:strong).should eq "\033E1"
    end
    it "should translate <u>" do
      BTPR880.startCode(:u).should eq "\033-1"
    end
  end

  describe "#endCode" do
    it "should translate </strong>" do
      BTPR880.endCode(:strong).should eq "\033E0"
    end
    it "should translate </u>" do
      BTPR880.endCode(:u).should eq "\033-0"
    end
  end

end

describe "BTPR880 Parser" do

  before(:each) do
    @parser = Thermal::Parser.new(BTPR880)
  end

  it "should translate html to BTPR880 valid print codes" do
    translated = @parser.process("<strong>bold<u>underline</u></strong>")
    translated.should eq "\033E1bold\033-1underline\033-0\033E0"
  end

end
