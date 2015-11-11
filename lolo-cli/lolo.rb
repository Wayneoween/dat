#!/usr/bin/env ruby

require 'rest-client'
require 'clamp'
require 'yaml'
require 'json'
require Dir.pwd + "/models/light"

$uri = "http://localhost:7777/api"
$config_file = "config.yml"
$key = nil

def set_api_key
  if $key = get_cfg("api_key")
    return $key
  end

  begin
    response = RestClient.post $uri,
      { 'devicetype' => "myappbar" }.to_json,
      :content_type => :json,
      :accept => :json
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

def set_cfg(key, value)
  File.open($config_file, "w") do |file|
    file.write({key => value}.to_yaml)
  end
end

def get_cfg(key)
  unless File.exist?($config_file)
    File.open($config_file, 'w'){}
  end
  cfg = YAML.load(File.read($config_file))
  if cfg && cfg[key]
    return cfg[key]
  end
end

def get_lights
  puts "Getting all lights..."
  ret = {}
  Light.all.each do |light|
    ret[light.id] =  {:name =>light.name}
  end
  puts ret.to_json
end

def get_light_by_id(id)
  light = Light.find(id)
  ret = {:id => light.id, :on => light.on, :name => light.name}.to_json
  puts ret
end

def set_light_on(id)
  light = Light.find(id)
  light.turn_on
end

def set_light_off(id)
  light = Light.find(id)
  light.turn_off
end

set_api_key

Clamp do

  subcommand "list", "List all lights." do
    def execute
      get_lights
    end
  end

  subcommand "on", "Switch a light on." do
  option ["-l", "--light"], "LIGHT_ID", "The Light.", :attribute_name => :light_id
    def execute
      set_light_on(light_id)
    end
  end

  subcommand "off", "Switch a light off." do
  option ["-l", "--light"], "LIGHT_ID", "The Light.", :attribute_name => :light_id
    def execute
      set_light_off(light_id)
    end
  end

end
