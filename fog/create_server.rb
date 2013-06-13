#!/usr/bin/env ruby

require 'fog'

domain   = ARGV.shift
ssl_cert = ARGV.shift
ssl_key  = ARGV.shift

aws_credentials = {
    :aws_access_key_id        => 'AKIAIDAJIKFPBARX233Q',
    :aws_secret_access_key    => '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'
}

connection = Fog::Compute.new(aws_credentials.merge(:provider => 'AWS'))

ami = 

server = compute.servers.create(
  image_id:  'ami-c30360aa',
  flavor_id: 'm1.medium',
  key_name:  '',
  tags: {
    'Name' => instance_name
  },
  groups:           config['security_group_name'],
  private_key_path: private_key_path
)

iam        = Fog::AWS::IAM.new(aws_credentials)

# def upload_server_certificate(certificate, private_key, name, options = {}).

certificate = File.read(ssl_cert)
private_key = File.read(ssl_key)
result = iam.upload_server_certificate(certificate, private_key, domain)
