class Light
  # TODO: get inspired by
  # https://github.com/soffes/hue/blob/master/lib/hue/light.rb
  # :)
  attr_accessor :id, :manufacturer, :name, :on
  def self.all_from_rest
    lights = []
    $logger.debug "Getting lights via #{$uri}/#{$key}/lights"
    response = RestClient.get $uri + "/#{$key}/lights"
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
    $logger.debug "Getting light #{id} via #{uri}/#{$key}/lights/#{id}"
    begin
      response = RestClient.get $uri + "/#{$key}/lights/#{id}"
    rescue
      return nil
    end

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
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:hue => hue}.to_json
  end

  def set_temp(temp)
    $logger.debug "Setting temperature of light #{id}"
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:ct => temp}.to_json
  end

  def turn_on
    $logger.debug "Turning light #{id} on"
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:on => true}.to_json
  end

  def turn_off
    $logger.debug "Turning light #{id} off"
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:on => false}.to_json
  end
end
