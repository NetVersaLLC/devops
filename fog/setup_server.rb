#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'fog'
require 'awesome_print'
require 'json'

# Fog.mock!

app_base        = '/home/ubuntu/contact'
aws_credentials = YAML.load(File.open("creds.yml"))
server          = JSON.parse(File.open("server.json").read)
keybase         = "#{ENV['HOME']}/Dropbox/new_keys/deploy/contact"

Fog.credentials = Fog.credentials.merge({ :private_key_path => keybase, :public_key_path => "#{keybase}.pub" })

compute = Fog::Compute.new(aws_credentials.merge(:provider => 'AWS'))
STDERR.puts "Server: #{server['id']}"
server = compute.servers.get server['id']

$server = server
def ssh(command)
  STDERR.puts command
  res = $server.ssh command
  STDERR.puts res.first.stderr
  STDERR.puts res.first.stdout
end

def scp(from,to)
  STDERR.puts "Copying #{from} -> #{to}"
  $server.scp from, to
end

# if 1 == 0
ssh "sudo add-apt-repository -y ppa:nginx/stable"
ssh "sudo add-apt-repository -y ppa:chris-lea/node.js"
ssh "sudo apt-get update"
ssh "sudo apt-get install -y build-essential git-core curl libcurl4-openssl-dev"
ssh "sudo apt-get install -y nginx"
ssh "sudo apt-get install -y mysql-client libmysqlclient-dev"
ssh "sudo apt-get install -y python-software-properties python g++ make software-properties-common node nodejs"
ssh "sudo apt-get install -y imagemagick libmagickwand-dev"
ssh "sudo apt-get install -y beanstalkd"
ssh "curl -L https://get.rvm.io | bash -s stable"
ssh "echo '[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && source \"$HOME/.rvm/scripts/rvm\"' >> .loadrvm"
ssh "cat .bashrc >> .loadrvm"
ssh "mv -v .loadrvm .bashrc"
ssh "rvm install 2.0 --default"
ssh "rvm 2.0 --default"
ssh "gem install therubyracer --no-ri --no-rdoc"
ssh "gem install unicorn --no-ri --no-rdoc"
ssh "mkdir -pv .ssh"
ssh "chmod 700 .ssh"
ssh "mkdir -pv #{app_base}/shared/config"
scp "config/unicorn.rb",      "#{app_base}/shared/config"
scp "config/application.yml", "#{app_base}/shared/config"
scp "config/database.yml",    "#{app_base}/shared/config"
scp "config/config",          ".ssh/"
scp "config/id_rsa",          ".ssh/"
scp "config/id_rsa.pub",      ".ssh/"
scp "config/sites",           ".ssh/"
scp "config/sites.pub",       ".ssh/"
scp "config/authorized_keys", ".ssh/"
scp "config/known_hosts",     ".ssh/"
scp "config/default.conf",    "default.conf"
scp "config/contact",         "init_script"
ssh "sudo mv -v init_script /etc/init.d/contact"
ssh "sudo chmod 755 /etc/init.d/contact"
ssh "sudo /usr/sbin/update-rc.d -f contact defaults"
ssh "sudo mv -v default.conf /etc/nginx/sites-available/default"
ssh "sudo service nginx restart"
