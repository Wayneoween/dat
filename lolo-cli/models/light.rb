class Light
  # TODO: get inspired by
  # https://github.com/soffes/hue/blob/master/lib/hue/light.rb
  # :)
  attr_accessor :id, :manufacturer, :name, :on
  def self.all_from_rest
    lights = []
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

    return lights
  end

  def self.all_from_cache
    lights = []
    if File.exist?("lights.cache")
      YAML.load(File.read("lights.cache"))
    end

    return lights
  end

  def self.all
    if all_from_cache
    else
      all_from_rest
    end
  end

  def self.find_by_id(id)
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
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:hue => hue}.to_json
  end

  def set_temp(temp)
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:ct => temp}.to_json
  end

  def turn_on
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:on => true}.to_json
  end

  def turn_off
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:on => false}.to_json
  end
end
