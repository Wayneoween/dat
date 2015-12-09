def set_api_key
  if $key = get_cfg("api_key")
    return $key
  end

  def try_login
    # Try default password first
    yield "delight:delight@"
    yield ""
  end

  try_login do |login|
    begin
      if host = get_cfg("api_host")
        response = RestClient.post "http://" + login + host + "/api",
          { 'devicetype' => "myappbar" }.to_json,
          :content_type => :json,
          :accept => :json
      end
    rescue
      puts "Unable to retrieve API-Key.\nPlease unlock your Gateway first!"
      exit 1
    end

    response = JSON.parse(response)

    if response && response.first["success"]
      key = response.first["success"]["username"]
      set_cfg("api_key", key)
      $key = key
      return key
    end
  end
end

def set_uri
  host = get_cfg("api_host")
  if host
    $host = host
    $uri = "http://" + host + "/api"
    return $uri
  end

  host = ask "Input hostname and port of gateway (default: localhost:80): "
  unless host.empty?
    $host = host
  end

  set_cfg("api_host", $host)
  $uri = "http://" + $host + "/api"
  return $uri
end

def set_cfg(key, value)
  cfg = YAML.load(File.read($config_file))
  if cfg
    cfg[key] = value
  else
    cfg = {key => value}
  end

  File.open($config_file, "w") do |file|
    file.write(cfg.to_yaml)
  end
end

def get_cfg(key)
  unless File.exist?($config_file)
    # If config file does not exist, touch it
    File.open($config_file, 'w'){}
  end

  cfg = YAML.load(File.read($config_file))

  if cfg && cfg[key]
    return cfg[key]
  end
end

def get_lights
  puts "Lights:"
  Light.all.each do |light|
    puts  "\t#{light.id} \t #{light.name}"
  end

  puts
end

def get_groups
  puts "Groups:"
  Group.all.each do |group|
    puts "\t#{group.id} \t #{group.name} \tLights: #{group.lights.map(&:name)}"
  end

  puts
end

def get_scenes
  puts "Scenes:"
  Scene.all.each do |scene|
    puts "\t#{scene.name} \t#{scene.group.name}"
  end

  puts
end

def get_light_by_id(id)
  light = Light.find(id)
  ret = {:id => light.id, :on => light.on, :name => light.name}.to_json
  puts ret
end
