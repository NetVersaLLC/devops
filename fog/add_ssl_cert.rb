#!/usr/bin/env ruby

require 'fog'
require 'awesome_print'

domain   = ARGV.shift
ssl_cert = ARGV.shift
ssl_key  = ARGV.shift

aws_credentials = YAML.load(File.open("creds.yml"))

iam        = Fog::AWS::IAM.new(aws_credentials)
# def upload_server_certificate(certificate, private_key, name, options = {}).
certificate = File.read(ssl_cert)
private_key = File.read(ssl_key)
result = iam.upload_server_certificate(certificate, private_key, domain)

ap result
