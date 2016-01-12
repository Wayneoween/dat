# A class to handle all group stuff
class Group

  # Identification attributes
  attr_accessor :id, :name, :light_ids

  # Constructor with a instance variable of all lights in this group
  def initialize
    @light_ids = []
  end

  # Populate the instance variable +@lights+ by asking the server.
  def lights
    lights = []
    light_ids.each do |light_id|
      lights << Light.find_by_id(light_id)
    end
    return lights
  end

  # Get all groups from the server and cache the information locally.
  def self.all_from_rest
    groups = []
    $logger.debug "Getting groups via #{$uri}/#{$key}/groups"
    response = get_request($uri + "/#{$key}/groups")
    response = JSON.parse(response)
    response.each do |nr, group|
      my_light_ids = []
      group_lights = get_request($uri + "/#{$key}/groups/#{nr}")
      group_lights = JSON.parse(group_lights)
      group_lights["lights"].each do |light_id|
        my_light_ids << light_id
      end
      g = Group.new
      g.id = nr
      g.light_ids = my_light_ids
      g.name = group["name"]
      groups << g
    end

    serialize(groups)

    return groups
  end

  # Write information to the cache file +group_cache.yml+.
  def self.serialize(groups)
    $logger.debug "Serializing #{groups.size} groups"
    serialized = YAML::dump(groups)
    File.open("group_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  # Alias for +all_from_rest+
  def self.update_cache
    self.all_from_rest
  end

  # Load information of groups from +group_cache.yml+ if it exists. Otherwise
  # fall back to +all_from_rest+.
  def self.all
    groups = []

    # If the cache exists, we assume its up-to-date
    if File.exist?("group_cache.yml")
      $logger.debug "Loading group cache..."
      groups = YAML.load(File.read("group_cache.yml"))
    else
      $logger.debug "Getting groups from server..."
      groups = all_from_rest
    end

    return groups
  end

  # Creates a new group and updates the cache.
  def self.add(name)
    $logger.debug "Adding group #{name} via #{$uri}/#{$key}/groups"
    post_request($uri + "/#{$key}/groups", {:name => name})
    Group.update_cache
  end

  # Find group by provided +name+. Look first in the cache file
  # +group_cache.yml+ if the +name+ is not found, try via API. If it isn't
  # there either, return an error.
  def self.find_by_name(name)
    $logger.debug "Getting group #{name}"
    Group.all.each do |group|
      return group if group.name == name
    end

    return nil
  end

  # Find group by provided +id+. Look first in the cache file +group_cache.yml+
  # if the +id+ is not found, try via API. If it isn't there either, return an
  # error.
  def self.find_by_id(id)
    $logger.debug "Getting group #{id}"
    Group.all.each do |group|
      return group if group.id == id
    end

    return nil
  end

  # Sets the color of a group.
  def set_color(hue, transition)
    options = hue.clone
    options["on"] = true
    options["transitiontime"] = transition
    $logger.debug "Setting color of group #{id}"
    put_request($uri + "/#{$key}/groups/#{id}/action", options)
  end

  # Sets either a +warm+ white or a +cold+ white.
  def set_temp(temp, transition)
    options = {}
    options["ct"] = temp
    options["on"] = true
    options["transitiontime"] = transition
    $logger.debug "Setting temperature of group #{id}"
    put_request($uri + "/#{$key}/groups/#{id}/action", options)
  end

  # Adds a +light+ to a group
  def add_light(light)
    $logger.debug "Add light #{light.name} to group #{id}"
    put_request($uri + "/#{$key}/groups/#{id}", {:lights => [light.id] + light_ids})
    Group.update_cache
  end

  # Deletes a group
  def delete
    $logger.debug "Delete group #{id}"
    delete_request($uri + "/#{$key}/groups/#{id}")
    Group.update_cache
  end

  # Turns a group on.
  def turn_on
    $logger.debug "Turning group #{id} on"
    put_request($uri + "/#{$key}/groups/#{id}/action", {:on => true})
  end

  # Turns a group off.
  def turn_off
    $logger.debug "Turning group #{id} off"
    put_request($uri + "/#{$key}/groups/#{id}/action", {:on => false})
  end
end
