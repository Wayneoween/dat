class Light
  # TODO: get inspired by
  # https://github.com/soffes/hue/blob/master/lib/hue/light.rb
  # :)
  attr_accessor :id, :manufacturer, :name, :on
  def self.all_from_rest
    lights = []
    $logger.debug "Getting lights via #{$uri}/#{$key}/lights"
    response = make_get_request($uri + "/#{$key}/lights")
    response = JSON.parse(response)
    response.each do |nr, light|
      l = Light.new
      l.id = nr
      l.manufacturer = light["manufacturer"]
      l.name = light["name"]
      l.on = light["state"]["on"]
      lights << l
    end

    # Update the cache
    serialize(lights)

    return lights
  end

  def self.serialize(lights)
    $logger.debug "Serializing #{lights.size} light(s)"
    serialized = YAML::dump(lights)
    File.open("light_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  def self.update_cache
    self.all_from_rest
  end

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

  def self.find_by_id(id)
    $logger.debug "Getting light #{id} via #{$uri}/#{$key}/lights/#{id}"
    response = make_get_request($uri + "/#{$key}/lights/#{id}")
    return nil unless response

    response = JSON.parse(response)
    l = Light.new
    l.id = id
    l.manufacturer = response["manufacturer"]
    l.name = response["name"]
    l.on = response["state"]["on"]

    return l
  end

  def self.find_by_name(name)
    Light.all.each do |light|
      return light if light.name == name
    end

    return nil
  end

  def set_color(hue)
    $logger.debug "Setting color of light #{id}"
    make_put_request($uri + "/#{$key}/lights/#{id}/state", {:hue => hue})
  end

  def set_temp(temp)
    $logger.debug "Setting temperature of light #{id}"
    make_put_request($uri + "/#{$key}/lights/#{id}/state", {:ct => temp})
  end

  def turn_on
    $logger.debug "Turning light #{id} on"
    make_put_request($uri + "/#{$key}/lights/#{id}/state", {:on => true})
  end

  def turn_off
    $logger.debug "Turning light #{id} off"
    make_put_request($uri + "/#{$key}/lights/#{id}/state", {:on => false})
  end
end
