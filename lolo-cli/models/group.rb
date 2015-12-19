class Group
  # TODO: get inspired by
  # https://github.com/soffes/hue/blob/master/lib/hue/group.rb
  # :)
  attr_accessor :id, :name, :on, :lights

  def initialize
    @lights = []
  end

  def lights
    $logger.debug "Getting lights from group #{id} via #{$uri}/#{$key}/groups/#{id}"
    response = make_get_request($uri + "/#{$key}/groups/#{id}")
    response = JSON.parse(response)
    response["lights"].each do |light_id|
      @lights << Light.find_by_id(light_id)
    end

    @lights
  end

  def self.all_from_rest
    groups = []
    $logger.debug "Getting groups via #{$uri}/#{$key}/groups"
    response = make_get_request($uri + "/#{$key}/groups")
    response = JSON.parse(response)
    response.each do |nr, group|
      g = Group.new
      g.id = nr
      g.name = group["name"]
      groups << g
    end

    # Update the cache
    serialize(groups)

    return groups
  end

  def self.serialize(groups)
    $logger.debug "Serializing #{groups.size} groups"
    serialized = YAML::dump(groups)
    File.open("group_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  def self.update_cache
    self.all_from_rest
  end

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

  def self.add(name)
    $logger.debug "Add group #{name} via #{$uri}/#{$key}/groups"
    make_post_request($uri + "/#{$key}/groups", {:name => name})
  end

  def self.find_by_name(name)
    # XXX: Maybe make group an instance variable so we don't load the cache again here
    $logger.debug "Getting group #{name}"
    Group.all.each do |group|
      return group if group.name == name
    end

    return nil
  end

  def self.find_by_id(id)
    $logger.debug "Getting group #{id}"
    Group.all.each do |group|
      return group if group.id == id
    end

    return nil
  end

  def set_color(hue)
    $logger.debug "Setting color of group #{id}"
    make_put_request($uri + "/#{$key}/groups/#{id}/action", {:hue => hue})
  end

  def set_temp(temp)
    $logger.debug "Setting temperature of group #{id}"
    make_put_request($uri + "/#{$key}/groups/#{id}/action", {:ct => temp})
  end

  def add_light(light)
    $logger.debug "Add light #{light.name} to group #{id}"
    make_put_request($uri + "/#{$key}/groups/#{id}", {:lights => [light.id]})
  end

  def delete
    $logger.debug "Delete group #{id}"
    make_delete_request($uri + "/#{$key}/groups/#{id}")
  end

  def turn_on
    $logger.debug "Turning group #{id} on"
    make_put_request($uri + "/#{$key}/groups/#{id}/action", {:on => true})
  end

  def turn_off
    $logger.debug "Turning group #{id} off"
    make_put_request($uri + "/#{$key}/groups/#{id}/action", {:on => false})
  end
end
