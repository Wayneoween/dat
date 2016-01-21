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

# Include all our helpers and models
require_relative "helper/api"
require_relative "helper/clamp"
require_relative "helper/color"
require_relative "models/group"
require_relative "models/light"
require_relative "models/scene"

# The default host where deCONZ is running
$host = "localhost:80"
# The default URI to the API Endpoint
$uri = "http://#{$host}/api"
# User defined settings go here
$config_file = "config.yml"
# The API Key for authentication
$key = nil
# The light or group or scene at hand
$light = nil
# List of allowed commands
$commands = ["update", "list", "delete", "add"]

$logger = Logger.new(STDOUT)
$logger.level = Logger::WARN

# Load user defined settings from config file if available
set_uri
# Use those settings for trying to retrieve the api key with default credentials
set_api_key

module Lolo

  class AddCommand < Clamp::Command
    subcommand "group", "Add a Group." do

      parameter "NAME", "name of group"

      def execute
        $logger.debug "Adding group #{name}"
        Group.add(name)
      end
    end

    subcommand "light", "Add a light to a group." do

      parameter "LIGHTNAME", "name or id of light"
      parameter "GROUPNAME", "name of id of group"

      def execute
        $logger.debug "Looking for light #{lightname}"
        light = Light.find_by_name(lightname)
        light = Light.find_by_id(lightname) if light.nil?
        return if light.nil?

        $logger.debug "Looking for group #{groupname}"
        group = Group.find_by_name(groupname)
        group = Group.find_by_id(groupname) if group.nil?
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

        $logger.debug "Looking for scene #{scenename}"
        scene = Scene.find_by_name(scenename)
        if not scene.nil?
          scene.update()
        else
          Scene.add(group, scenename)
        end
      end
    end
  end

  class DeleteCommand < Clamp::Command
    subcommand "group", "Delete a group." do

      parameter "GROUPNAME", "name of group"

      def execute
        $logger.debug "Looking for group #{groupname}"
        group = Group.find_by_name(groupname)
        return if group.nil?

        $logger.debug "Deleting group #{groupname}"
        group.delete
      end

    end

    subcommand "scene", "Delete a scene." do

      parameter "SCENENAME", "name of scene"

      def execute
        $logger.debug "Looking for scene #{scenename}"
        scene = Scene.find_by_name(scenename)
        return if scene.nil?

        $logger.debug "Deleting scene #{scenename}"
        scene.delete
      end

    end
  end

  class LightGroupCommand < Clamp::Command
    option "-t", "N", "Set transition time in seconds", :attribute_name => "transition", :default => 9 do |s|
      (Float(s)*10).to_i
    end

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

    subcommand "hex", "Set color defined by user input." do
      parameter "COLOR", "color", :attribute_name => :color do |s|
        String(s)
      end

      def execute
        hue = hex_to_hsv(color)
        $light.set_color(hue, transition)
      end
    end

    subcommand "red", "Set light color to red." do
      def execute
        $logger.debug "Turning light #{$light} to red"
        $light.set_color(HUE_MAP[:red], transition)
      end
    end

    subcommand "blue", "Set light color to blue." do
      def execute
        $logger.debug "Turning light #{$light} to blue"
        $light.set_color(HUE_MAP[:blue], transition)
      end
    end

    subcommand "green", "Set light color to green." do
      def execute
        $logger.debug "Turning light #{$light} to green"
        $light.set_color(HUE_MAP[:green], transition)
      end
    end

    subcommand "white", "Set light color to white." do
      def execute
        $logger.debug "Turning light #{$light} to white"
        $light.set_color(HUE_MAP[:white], transition)
      end
    end

    subcommand "warm", "Set light temperature to warm." do
      def execute
        $logger.debug "Turning light #{$light} to white warm"
        $light.set_temp(TEMP_MAP[:warm], transition)
      end
    end

    subcommand "cold", "Set light temperature to cold." do
      def execute
        $logger.debug "Turning light #{$light} to white cold"
        $light.set_temp(TEMP_MAP[:cold], transition)
      end
    end

    subcommand "bri", "Set brightness." do
      parameter "BRIGHTNESS", "brightness", :attribute_name => :brightness do |s|
        Integer(s)
      end

      def execute
        $logger.debug "Turning light #{$light} to brightness #{brightness}"
        $light.set_brightness(brightness, transition)
      end
    end
  end

  class LightCommand < Clamp::Command
    subcommand SubcommandLight.new, "Switch a light on/off.", LightGroupCommand
  end

  class GroupCommand < Clamp::Command
    subcommand SubcommandGroup.new, "Switch a group on/off.", LightGroupCommand
  end

  class SceneCommand < Clamp::Command

    subcommand SubcommandScene.new, "Scene name." do

      subcommand "on", "Switch scene on" do
        def execute
          $logger.debug "Turning on scene #{$light}"
          $light.turn_on
        end
      end

      subcommand "off", "Switch scene off" do
        def execute
          $logger.debug "Turning off scene #{$light}"
          $light.turn_off
        end
      end

    end
  end

  class UpdateCommand < Clamp::Command
    def execute
      $logger.debug "Updating light cache"
      Light.update_cache
      $logger.debug "Updating group cache"
      Group.update_cache
      $logger.debug "Updating scene cache"
      Scene.update_cache
    end
  end

  class ListCommand < Clamp::Command
    def execute
      $logger.debug "Getting lights"
      get_lights
      $logger.debug "Getting groups"
      get_groups
      $logger.debug "Getting scenes"
      get_scenes
    end
  end

  class MainCommand < Clamp::Command

    option "-d", :flag, "Enable debug output", :attribute_name => "debug" do |s|
      $logger.level = Logger::DEBUG
    end

    subcommand "list", "List all lights and groups.", ListCommand
    subcommand "update", "Update cache of lights, groups and scenes.", UpdateCommand

    subcommand "light", "Change a specific light.", LightCommand
    subcommand "group", "Change a specific group.", GroupCommand
    subcommand "scene", "Change a specific scene.", SceneCommand

    subcommand "add", "Add a group or a light to a group.", AddCommand
    subcommand "delete", "Delete a group or scene.", DeleteCommand

  end
end

Lolo::MainCommand.run
