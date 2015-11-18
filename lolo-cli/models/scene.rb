class Scene

  attr_accessor :id, :name, :group

  def self.all
    scenes = []
    Group.all.each do |group|
      response = RestClient.get $uri + "/#{$key}/groups/" + group.id + "/scenes"
      next if response.empty?

      response = JSON.parse(response)
      response.each do |nr, scene|
        s = Scene.new
        s.id = nr
        s.name = scene["name"]
        s.group = group
        scenes << s
      end
    end
    return scenes
  end

  def self.add(name)
    RestClient.post $uri + "/#{$key}/groups", {:name => name}.to_json
  end

  def self.find_by_name(name)
    Scene.all.each do |scene|
      return scene if scene.name == name
    end
    return nil
  end

  def turn_on
    RestClient.put $uri + "/#{$key}/groups/#{group.id}/scenes/#{id}/recall", ""
  end

  def update
    RestClient.put $uri + "/#{$key}/groups/#{group.id}/scenes/#{id}/store", {:lights => [light.id]}.to_json
  end

  def self.create(group, name)
    RestClient.post $uri + "/#{$key}/groups/#{group.id}/scenes", {:name => name}.to_json
  end
end
