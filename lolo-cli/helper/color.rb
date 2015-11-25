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

def hex_to_rgb(s)
  if m = s.match(/^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i)
    return { "r" => m[1].to_i(16),
             "g" => m[2].to_i(16),
             "b" => m[3].to_i(16) }
  elsif m = s.match(/^#?([0-9a-f])([0-9a-f])([0-9a-f])$/i)
    return { "r" => (m[1] + m[1]).to_i(16),
             "g" => (m[2] + m[2]).to_i(16),
             "b" => (m[3] + m[3]).to_i(16) }
  else
    puts "invalid hex sequence '#{s}'"
  end
end

def rgb_to_hsv(r, g, b)
  r = r / 255.0
  g = g / 255.0
  b = b / 255.0
  max = [r, g, b].max
  min = [r, g, b].min
  delta = max - min
  v = max * 100

  if (max != 0.0)
      s = delta / max *100
  else
      s = 0.0
  end

  if (s == 0.0)
      h = 0.0
  else
    if (r == max)
      h = (g - b) / delta
    elsif (g == max)
      h = 2 + (b - r) / delta
    elsif (b == max)
      h = 4 + (r - g) / delta
    end

    h *= 60.0

    if (h < 0)
      h += 360.0
    end
  end

  h = (65535/(360/h.to_f)).to_i
  s = (255*(s.to_f/100)).to_i
  v = (255*(v.to_f/100)).to_i

  return {:hue => h, :sat => s, :bri => v}
end

def hex_to_hsv(hex)
  rgb = hex_to_rgb(hex)
  hsv = rgb_to_hsv(rgb["r"], rgb["g"], rgb["b"])
  return hsv
end
