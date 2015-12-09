class Group
  # TODO: get inspired by
  # https://github.com/soffes/hue/blob/master/lib/hue/group.rb
  # :)
  attr_accessor :id, :name, :on, :lights

  def self.all_from_rest
    groups = []
    response = RestClient.get $uri + "/#{$key}/groups"
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
    serialized = YAML::dump(groups)
    File.open("group_cache.yml", "w") do |file|
      file.write(serialized)
    end
  end

  def self.all
    groups = []

    # If the cache exists, we assume its up-to-date
    if File.exist?("group_cache.yml")
      puts "Loading group cache..."
      groups = YAML.load(File.read("group_cache.yml"))
    else
      puts "Getting groups from server..."
      groups = all_from_rest
    end

    return groups
  end

  def self.add(name)
    RestClient.post $uri + "/#{$key}/groups", {:name => name}.to_json
  end

  def self.find_by_name(name)
    # XXX: Maybe make group an instance variable so we don't load the cache again here
    Group.all.each do |group|
      return group if group.name == name
    end

    return nil
  end

  def set_color(hue)
    RestClient.put $uri + "/#{$key}/groups/#{id}/action", {:hue => hue}.to_json
  end

  def set_temp(temp)
    RestClient.put $uri + "/#{$key}/groups/#{id}/action", {:ct => temp}.to_json
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
