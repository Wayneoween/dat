# https://de.wikipedia.org/wiki/HSV-Farbraum
HUE_MAP = {
  :green => (65535/(360/106.to_f)).to_i,
  :red => (65535/(360/360.to_f)).to_i,
  :blue => (65535/(360/233.to_f)).to_i,
  :white => 1
}

TEMP_MAP = {
  :warm => 500,
  :cold => 153
}
