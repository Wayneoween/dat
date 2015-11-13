#!/usr/bin/env ruby

require 'rest-client'
require 'clamp'
require 'yaml'
require 'json'
require_relative "models/light"

$uri = "http://localhost:7777/api"
$config_file = "config.yml"
$key = nil
$light = nil

# Das umrechnen RGB zu HUE HSV ist kompliziert:
# https://de.wikipedia.org/wiki/HSV-Farbraum
# Viellicht gibt es ein Gem?
HUE_MAP = {
  :green => (65535/(360/106.to_f)).to_i,
  :red => (65535/(360/360.to_f)).to_i,
  :blue => (65535/(360/233.to_f)).to_i,
  :white => 1
}

TEMP_MAP = {
  :warm => 500,
  :cold => 153
}

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
    if $light = Light.find_by_name(other_object)
      return true
    end
    if $light = Light.find_by_id(other_object)
      return true
    end
    return false
  end

  # Used to beautify the Clamp usage.
  def to_s
    return "<light|group> <on|off>"
  end
end

Clamp do

  subcommand "list", "List all lights." do
    def execute
      get_lights
    end
  end

  subcommand SubcommandLightGroup.new, "Switch a light (by name or id) or group on/off." do

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

    subcommand "red", "Set light color to red." do
      def execute
        $light.set_color(HUE_MAP[:red])
      end
    end

    subcommand "blue", "Set light color to blue." do
      def execute
        $light.set_color(HUE_MAP[:blue])
      end
    end

    subcommand "green", "Set light color to green." do
      def execute
        $light.set_color(HUE_MAP[:green])
      end
    end

    subcommand "white", "Set light color to white." do
      def execute
        $light.set_color(HUE_MAP[:white])
      end
    end


    subcommand "warm", "Set light temperature to warm." do
      def execute
        $light.set_temp(TEMP_MAP[:warm])
      end
    end

    subcommand "cold", "Set light temperature to cold." do
      def execute
        $light.set_temp(TEMP_MAP[:cold])
      end
    end
  end

end
