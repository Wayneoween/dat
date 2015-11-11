#!/usr/bin/env ruby

require 'rest-client'
require 'clamp'
require 'yaml'
require 'json'
require Dir.pwd + "/models/light"

$uri = "http://localhost:7777/api"
$config_file = "config.yml"
$key = nil
$light = nil

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

set_api_key

class SubcommandLightGroup

  # This function is called from Clamp. Clamp tries to find
  # a subcommand by comparing the subcommand to the string passed
  # on the console. This hijacks the comparison and looks for
  # Lights or Groups that match the specified name.
  def ==(other_object)
    # TODO: use local json instead
    #Group.all.each do |light|
    #  if light.name == other_object
    #    $light = light
    #    return true
    #  end
    #end
    Light.all.each do |light|
      if light.name == other_object
        $light = light
        return true
      end
    end
    return false
  end

  # Used to beautify the Clamp usage.
  def to_s
    return "<light|group>"
  end
end

Clamp do

  subcommand "list", "List all lights." do
    def execute
      get_lights
    end
  end

  subcommand SubcommandLightGroup.new, "Switch a light or group on/off." do

    subcommand "on", "Switch on." do
      def execute
        $light.turn_on
      end
    end

    subcommand "off", "Switch off." do
      def execute
        $light.turn_off
      end
    end

  end

end
