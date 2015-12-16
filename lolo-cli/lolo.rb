#!/usr/bin/env ruby

begin
  require 'clamp'
  require 'highline/import'
  require 'json'
  require 'logger'
  require 'rest-client'
  require 'yaml'
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

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

set_uri
set_api_key

Clamp do

  subcommand "update", "Update cache of lights, groups and scenes." do
    def execute
     $logger.debug "Updating light cache"
      Light.update_cache
     $logger.debug "Updating group cache"
      Group.update_cache
     $logger.debug "Updating scene cache"
      Scene.update_cache
    end
  end

  subcommand "list", "List all lights and groups." do
    def execute
     $logger.debug "Getting lights"
      get_lights
     $logger.debug "Getting groups"
      get_groups
     $logger.debug "Getting scenes"
      get_scenes
    end
  end

  subcommand SubcommandScene.new, "Switch to a specific scene." do
    def execute
     $logger.debug "Turning on scene #{$light}"
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
       $logger.debug "Turning on light #{$light}"
        $light.turn_on
      end
    end

    subcommand "off", "Switch off." do
      def execute
       $logger.debug "Turning off light #{$light}"
        $light.turn_off
      end
    end

    subcommand "red", "Set light color to red." do
      def execute
       $logger.debug "Turning light #{$light} to red"
        $light.set_color(HUE_MAP[:red])
      end
    end

    subcommand "blue", "Set light color to blue." do
      def execute
       $logger.debug "Turning light #{$light} to blue"
        $light.set_color(HUE_MAP[:blue])
      end
    end

    subcommand "green", "Set light color to green." do
      def execute
       $logger.debug "Turning light #{$light} to green"
        $light.set_color(HUE_MAP[:green])
      end
    end

    subcommand "white", "Set light color to white." do
      def execute
       $logger.debug "Turning light #{$light} to white"
        $light.set_color(HUE_MAP[:white])
      end
    end

    subcommand "warm", "Set light temperature to warm." do
      def execute
       $logger.debug "Turning light #{$light} to white warm"
        $light.set_temp(TEMP_MAP[:warm])
      end
    end

    subcommand "cold", "Set light temperature to cold." do
      def execute
       $logger.debug "Turning light #{$light} to white cold"
        $light.set_temp(TEMP_MAP[:cold])
      end
    end
  end

  subcommand "add", "add a group with name or a light to a group" do

    subcommand "group", "Add a Group." do

      parameter "NAME", "name of group"

      def execute
       $logger.debug "Adding group #{name}"
        Group.add(name)
      end
    end

    subcommand "light", "Add a light to a group." do

      parameter "LIGHTNAME", "name of light"
      parameter "GROUPNAME", "name of group"

      def execute
       $logger.debug "Looking for light #{lightname}"
        light = Light.find_by_name(lightname)
        return if light.nil?

       $logger.debug "Looking for group #{groupname}"
        group = Group.find_by_name(groupname)
        return if group.nil?

       $logger.debug "Adding light #{lightname} to group #{groupname}"
        group.add_light(light)
      end
    end

    subcommand "scene", "Add a new scene to a group." do

      parameter "SCENENAME", "name of scene"
      parameter "GROUPNAME", "name of group"

      def execute
       $logger.debug "Looking for group #{groupname}"
        group = Group.find_by_name(groupname)
        return if group.nil?

       $logger.debug "Looking for scene #{scene}"
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
