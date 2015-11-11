#!/usr/bin/env ruby

require 'sinatra'
require 'rest-client'
require 'yaml'
require 'json'
require Dir.pwd + "/models/light"

$uri = "http://localhost:7777/api"
$config_file = "config.yml"
$key = nil

helpers do
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
      return nil
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
end

before do
  set_api_key
end

get '/lights' do
  if $key.nil?
    return "Please unlock your Gateway"
  end
  ret = {}
  Light.all.each do |light|
    ret[light.id] =  {:name =>light.name}
  end
  return ret.to_json
end

get '/light/:id' do
  if $key.nil?
    return "Please unlock your Gateway"
  end
  light = Light.find(params[:id])
  ret = {:id => light.id, :on => light.on, :name => light.name}.to_json
  return ret
end

get '/light/:id/on' do
  if $key.nil?
    return "Please unlock your Gateway"
  end
  light = Light.find(params[:id])
  light.turn_on
end

get '/light/:id/off' do
  if $key.nil?
    return "Please unlock your Gateway"
  end
  light = Light.find(params[:id])
  light.turn_off
end
