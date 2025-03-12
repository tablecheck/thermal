class HTML < Thermal::Printer

  TRANSLATE = {
    :strong => ["<strong>", "</strong>"],
    :underline => ["<u>", "</u>"],
    :mark => ["<mark>", "</mark>"],
    :br => ["<br/>"]
  }

  def self.translate
    TRANSLATE
  end

end
