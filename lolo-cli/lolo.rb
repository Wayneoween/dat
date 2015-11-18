#!/usr/bin/env ruby

begin
  require 'rest-client'
  require 'clamp'
  require 'yaml'
  require 'json'
rescue LoadError => err
  puts "Necessary gem missing:\n  #{err}"
  exit 1
end

require_relative "helper/api"
require_relative "helper/clamp"
require_relative "models/light"
require_relative "models/group"
require_relative "models/scene"

$uri = "http://localhost:80/api"
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

set_api_key

Clamp do

  subcommand "list", "List all lights and groups." do
    def execute
      get_lights
      get_groups
      get_scenes
    end
  end

  subcommand SubcommandScene.new, "Switch to a specific scene." do
    def execute
      $light.turn_on
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

  subcommand "add", "add a group with name or a light to a group" do

    subcommand "group", "Add a Group." do

      parameter "NAME", "name of group"

      def execute
        Group.add(name)
      end
    end

    subcommand "light", "Add a light to a group." do

      parameter "LIGHTNAME", "name of light"
      parameter "GROUPNAME", "name of group"

      def execute
        light = Light.find_by_name(lightname)
        return if light.nil?
        group = Group.find_by_name(groupname)
        return if group.nil?
        group.add_light(light)
      end
    end

    subcommand "scene", "Add a scene from a group." do

      parameter "SCENENAME", "name of scene"
      parameter "GROUPNAME", "name of group"

      def execute
        group = Group.find_by_name(groupname)
        return if group.nil?

        scene = Scene.find_by_name(scene)
        if not scene.nil?
          scene.update()
        else
          Scene.create(group, scenename)
       end
      end
    end
  end

  subcommand "delete", "delete a group by name" do

    parameter "GROUPNAME", "name of group"

    def execute
      group = Group.find_by_name(groupname)
      return if group.nil?
      group.delete
    end

  end
end
