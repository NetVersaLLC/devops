#!/usr/bin/env ruby

require 'fog'
require 'securerandom'
require 'awesome_print'

name     = ARGV.shift
keybase  = ARGV.shift

aws_credentials = YAML.load(File.open("creds.yml"))
# Fog.mock!

key_name = 'contact'
compute = Fog::Compute.new(aws_credentials.merge(:provider => 'AWS'))

Fog.credentials = Fog.credentials.merge({ :private_key_path => keybase, :public_key_path => "#{keybase}.pub" })
res = compute.import_key_pair(key_name, IO.read("#{keybase}.pub")) if compute.key_pairs.get(key_name).nil?

ap res

__END__
iam        = Fog::AWS::IAM.new(aws_credentials)

# def upload_server_certificate(certificate, private_key, name, options = {}).

certificate = File.read(ssl_cert)
private_key = File.read(ssl_key)
result = iam.upload_server_certificate(certificate, private_key, domain)
