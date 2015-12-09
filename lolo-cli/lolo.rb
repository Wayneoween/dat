#!/usr/bin/env ruby

begin
  require 'rest-client'
  require 'clamp'
  require 'yaml'
  require 'json'
  require "highline/import"
rescue LoadError => err
  puts "Necessary gem missing:\n  #{err}"
  exit 1
end

require_relative "helper/api"
require_relative "helper/clamp"
require_relative "helper/color"
require_relative "models/group"
require_relative "models/light"
require_relative "models/scene"

$host = "localhost:80"
$uri = "http://localhost:80/api"
$config_file = "config.yml"
$key = nil
$light = nil

set_uri
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

  # XXX: Its *probably* better to use a switch for telling lolo which one we want
  #      because now we read the light cache, and then the group cache to determine
  #      if the given name is in any of those. What if a light has the same name as
  #      a group?
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

  subcommand "delete", "delete a group or scene" do

    subcommand "group", "Delete a group." do

      parameter "GROUPNAME", "name of group"

      def execute
        group = Group.find_by_name(groupname)
        return if group.nil?
        group.delete
      end

    end

    subcommand "scene", "Delete a scene." do

      parameter "SCENENAME", "name of scene"

      def execute
        scene = Scene.find_by_name(scenename)
        return if scene.nil?
        scene.delete
      end

    end
  end
end
