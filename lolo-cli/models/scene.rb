class Scene
  # TODO: get inspired by
  # https://github.com/soffes/hue/blob/master/lib/hue/scene.rb
  # :)
  attr_accessor :id, :name, :group

  def self.all_from_rest
    scenes = []
    Group.all.each do |group|
      $logger.debug "Getting scenes in groups via #{$uri}/#{$key}/groups/#{group.id}/scenes"
      response = get_request($uri + "/#{$key}/groups/" + group.id + "/scenes")
      next if response.empty?

      response = JSON.parse(response)
      $logger.debug "Response from server is:\n#{response}"

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
    $logger.debug "Serializing #{scenes.size} scene(s)"
    serialized = YAML::dump(scenes)
    File.open("scene_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  def self.update_cache
    self.all_from_rest
  end

  def self.all
    scenes = []

    # If the cache exists, we assume its up-to-date
    if File.exist?("scene_cache.yml")
      $logger.debug "Loading scene cache"
      scenes = YAML.load(File.read("scene_cache.yml"))
    else
      $logger.debug "Getting scenes from server"
      scenes = all_from_rest
    end

    return scenes
  end

  def self.find_by_name(name)
    Scene.all.each do |scene|
      return scene if scene.name == name
    end

    return nil
  end

  def self.find_by_id(id)
    Scene.all.each do |scene|
      return scene if scene.id == id
    end

    return nil
  end

  def turn_on
    $logger.debug "Turning scene #{id} on"
    put_request($uri + "/#{$key}/groups/#{group.id}/scenes/#{id}/recall", "")
  end

  def update
    $logger.debug "Saving changes in scene #{id} in #{group.name}"
    put_request($uri + "/#{$key}/groups/#{group.id}/scenes/#{id}/store", {:lights => [light.id]})
  end

  def self.create(group, name)
    $logger.debug "Adding scene #{name} to group #{group.name}"
    post_request($uri + "/#{$key}/groups/#{group.id}/scenes", {:name => name})
    Scene.update_cache
  end

  def delete
    delete_request($uri + "/#{$key}/groups/#{group.id}/scenes/#{id}")
    Scene.update_cache
  end
end
