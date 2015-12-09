class Scene
  # TODO: get inspired by
  # https://github.com/soffes/hue/blob/master/lib/hue/scene.rb
  # :)
  attr_accessor :id, :name, :group

  def self.all_from_rest
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

    # Update the cache
    serialize(scenes)

    return scenes
  end

  def self.serialize(scenes)
    serialized = YAML::dump(scenes)
    File.open("scene_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  def self.all
    scenes = []

    # If the cache exists, we assume its up-to-date
    if File.exist?("scene_cache.yml")
      puts "Loading scene cache..."
      scenes = YAML.load(File.read("scene_cache.yml"))
    else
      puts "Getting scenes from server..."
      scenes = all_from_rest
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

  def delete
    RestClient.delete $uri + "/#{$key}/groups/#{group.id}/scenes/#{id}"
  end
end
