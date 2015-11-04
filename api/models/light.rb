class Light

  attr_accessor :id, :manufacturer, :name, :on
  def self.all
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

  def self.find(id)
    response = RestClient.get $uri + "/#{$key}/lights/#{id}"
    response = JSON.parse(response)
    l = Light.new
    l.id = id
    l.manufacturer = response["manufacturer"]
    l.name = response["name"]
    l.on = response["state"]["on"]
    return l
  end

  def turn_on
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:on => true}.to_json
  end

  def turn_off
    RestClient.put $uri + "/#{$key}/lights/#{id}/state", {:on => false}.to_json
  end
end
