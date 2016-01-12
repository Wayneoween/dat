# https://de.wikipedia.org/wiki/HSV-Farbraum
HUE_MAP = {
  :green => { :hue => (65535/(360/140.to_f)).to_i, :sat => 255, :bri => 255 },
  :red => { :hue => (65535/(360/360.to_f)).to_i, :sat => 255, :bri => 255 },
  :blue => { :hue => (65535/(360/233.to_f)).to_i, :sat => 255, :bri => 255 },
  :white => { :hue => 0, :sat => 0, :bri => 255 },
}

TEMP_MAP = {
  :warm => 500,
  :cold => 153
}
