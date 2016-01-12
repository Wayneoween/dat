# A class to handle all scene stuff
class Scene

  # Identification attributes
  attr_accessor :id, :name, :group

  # Get all scenes from the server and cache the information locally.
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

    serialize(scenes)

    return scenes
  end

  # Write information to the cache file +scene_cache.yml+.
  def self.serialize(scenes)
    $logger.debug "Serializing #{scenes.size} scene(s)"
    serialized = YAML::dump(scenes)
    File.open("scene_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  # Alias for +all_from_rest+
  def self.update_cache
    self.all_from_rest
  end

  # Load information of scenes from +scene_cache.yml+ if it exists. Otherwise
  # fall back to +all_from_rest+.
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

  # Find scene by provided +name+. Look first in the cache file
  # +scene_cache.yml+ if the +name+ is not found, try via API. If it isn't
  # there either, return an error.
  def self.find_by_name(name)
    Scene.all.each do |scene|
      return scene if scene.name == name
    end

    return nil
  end

  # Find scene by provided +id+. Look first in the cache file +scene_cache.yml+
  # if the +id+ is not found, try via API. If it isn't there either, return an
  # error.
  def self.find_by_id(id)
    Scene.all.each do |scene|
      return scene if scene.id == id
    end

    return nil
  end

  # Turns a scene on.
  def turn_on
    $logger.debug "Turning scene #{id} on"
    put_request($uri + "/#{$key}/groups/#{group.id}/scenes/#{id}/recall", "")
  end

  # Turns a scene off.
  def turn_off
    $logger.debug "Turning scene #{id} off"
    Group.find_by_id(group.id).turn_off
  end

  # Update the color information of the scene on the server.
  def update
    $logger.debug "Saving changes in scene #{id} in #{group.name}"
    put_request($uri + "/#{$key}/groups/#{group.id}/scenes/#{id}/store", {:name => name})
  end

  # Creates a new scene and updates the cache.
  def self.add(group, name)
    $logger.debug "Adding scene #{name} to group #{group.name}"
    post_request($uri + "/#{$key}/groups/#{group.id}/scenes", {:name => name})
    Scene.update_cache
  end

  # Deletes a scene and updates the cache.
  def delete
    delete_request($uri + "/#{$key}/groups/#{group.id}/scenes/#{id}")
    Scene.update_cache
  end
end
