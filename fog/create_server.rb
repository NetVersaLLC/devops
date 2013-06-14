#!/usr/bin/env ruby

require 'fog'
require 'securerandom'
require 'awesome_print'

key_name = 'contact'

aws_credentials = YAML.load(File.open("creds.yml"))
compute = Fog::Compute.new(aws_credentials.merge(:provider => 'AWS'))
server = compute.servers.create(
  :image_id =>  'ami-c30360aa',
  :flavor_id => 'm1.medium',
  :key_name =>  key_name,
  :tags => {
    'Name' => "Citation Server - #{Time.now.to_i.to_s}",
    'App'  => 'Citation Server'
  },
  :groups =>   'Citation Server'
)
STDERR.puts "Setup server: #{server.id}"
server.wait_for { ready? }
File.open("server.json", "w").write server.to_json
