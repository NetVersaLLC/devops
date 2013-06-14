#!/usr/bin/env ruby

require 'fog'
require 'awesome_print'

domain   = ARGV.shift

aws_credentials = YAML.load(File.open("creds.yml"))

iam        = Fog::AWS::IAM.new(aws_credentials)
# def upload_server_certificate(certificate, private_key, name, options = {}).
result = iam.delete_server_certificate(domain)

ap result
