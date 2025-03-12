require "socket"

class BTPR880 < Thermal::Printer

  ESC = 27.chr
  GS = 29.chr
  CODES = {
    :bold => ESC+"E",
    :underline => ESC+"-",
    :small => ESC+"M",
    :invert => GS+"B",
    :linebreak => "\n"
  }

  TRANSLATE = {
    :strong => [CODES[:bold]+"1", CODES[:bold]+"0"],
    :u => [CODES[:underline]+"1", CODES[:underline]+"0"],
    :small => [CODES[:small]+"1", CODES[:small]+"0"],
    :mark => [CODES[:invert]+"1", CODES[:invert]+"0"],
    :br => [CODES[:linebreak], ""]
  }

  def self.translate
    TRANSLATE
  end

  def self.print(ip, port=9001, &block)
    sock = TCPSocket.new(ip, port)
    yield sock if block_given?
    sock.close
  end

end
