class Group

  attr_accessor :id, :name, :on, :lights

  def initialize
    @lights = []
  end

  def lights
    response = RestClient.get $uri + "/#{$key}/groups/#{id}"
    response = JSON.parse(response)
    response["lights"].each do |light_id|
      @lights << Light.find_by_id(light_id)
    end
    @lights
  end

  def self.all
    groups = []
    response = RestClient.get $uri + "/#{$key}/groups"
    response = JSON.parse(response)
    response.each do |nr, group|
      g = Group.new
      g.id = nr
      g.name = group["name"]
      groups << g
    end
    return groups
  end

  def self.add(name)
    RestClient.post $uri + "/#{$key}/groups", {:name => name}.to_json
  end

  def self.find_by_name(name)
    Group.all.each do |group|
      return group if group.name == name
    end
    return nil
  end

  def add_light(light)
    RestClient.put $uri + "/#{$key}/groups/#{id}", {:lights => [light.id]}.to_json
  end

  def delete
    RestClient.delete $uri + "/#{$key}/groups/#{id}"
  end

  def turn_on
    RestClient.put $uri + "/#{$key}/groups/#{id}/action", {:on => true}.to_json
  end

  def turn_off
    RestClient.put $uri + "/#{$key}/groups/#{id}/action", {:on => false}.to_json
  end
end
