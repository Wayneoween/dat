# A class to handle all single-light stuff
class Light

  # Identification attributes
  attr_accessor :id, :name

  # Get all lights from the server and cache the information locally.
  def self.all_from_rest
    lights = []
    $logger.debug "Getting lights via #{$uri}/#{$key}/lights"
    response = get_request($uri + "/#{$key}/lights")
    response = JSON.parse(response)
    response.each do |nr, light|
      l = Light.new
      l.id = nr
      l.name = light["name"]
      lights << l
    end

    serialize(lights)

    return lights
  end

  # Write information to the cache file +light_cache.yml+.
  def self.serialize(lights)
    $logger.debug "Serializing #{lights.size} light(s)"
    serialized = YAML::dump(lights)
    File.open("light_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  # Alias for +all_from_rest+
  def self.update_cache
    self.all_from_rest
  end

  # Load information of lights from +light_cache.yml+ if it exists. Otherwise
  # fall back to +all_from_rest+.
  def self.all
    lights = []

    # If the cache exists, we assume its up-to-date
    if File.exist?("light_cache.yml")
      $logger.debug "Loading light cache"
      lights = YAML.load(File.read("light_cache.yml"))
    else
      $logger.debug "Getting lights from server"
      lights = all_from_rest
    end

    return lights
  end

  # Find light by provided +id+. Look first in the cache file +light_cache.yml+
  # if the +id+ is not found, try via API. If it isn't there either, return an
  # error.
  def self.find_by_id(id)
    $logger.debug "Getting light #{id}"
    Light.all.each do |light|
      return light if light.id == id
    end

    return nil
  end

  # Find light by provided +name+. Look first in the cache file
  # +light_cache.yml+ if the +name+ is not found, try via API. If it isn't
  # there either, return an error.
  def self.find_by_name(name)
    Light.all.each do |light|
      return light if light.name == name
    end

    return nil
  end

  # Sets the color of a lamp.
  def set_color(hue, transition)
    options = hue.clone
    options["on"] = true
    options["transitiontime"] = transition
    $logger.debug "Setting color of light #{id}"
    put_request($uri + "/#{$key}/lights/#{id}/state", options)
  end

  # Sets either a +warm+ white or a +cold+ white.
  def set_temp(temp, transition)
    options = {}
    options["bri"] = 255
    options["ct"] = temp
    options["on"] = true
    options["transitiontime"] = transition
    $logger.debug "Setting temperature of light #{id}"
    put_request($uri + "/#{$key}/lights/#{id}/state", options)
  end

  # Sets the brightness of a lamp.
  def set_brightness(bri, transition)
    options = {}
    options["bri"] = bri
    options["on"] = true
    options["transitiontime"] = transition
    $logger.debug "Setting brightness of light #{id}"
    put_request($uri + "/#{$key}/lights/#{id}/state", options)
  end

  # Turns a light on.
  def turn_on
    $logger.debug "Turning light #{id} on"
    put_request($uri + "/#{$key}/lights/#{id}/state", {:on => true})
  end

  # Turns a light off.
  def turn_off
    $logger.debug "Turning light #{id} off"
    put_request($uri + "/#{$key}/lights/#{id}/state", {:on => false})
  end
end
