#!/usr/bin/env ruby

require 'fog'
require 'awesome_print'
require 'json'

# Fog.mock!

domain = ARGV.shift

aws_credentials = YAML.load(File.open("creds.yml"))

api        = Fog::AWS::ELB.new(aws_credentials)
iam        = Fog::AWS::IAM.new(aws_credentials)
result = iam.list_server_certificates({'PathPrefix' => '/'})

arn = nil
result.body['Certificates'].each do |cert|
  if cert['ServerCertificateName'] == domain
    ap cert
    arn = cert['Arn']
  end
end

if arn.nil?
  STDERR.puts "Certificate ID not found for: #{domain}"
  exit 1
end

STDERR.puts "Got certificate id: #{arn}"

lb = nil
api.load_balancers.each do |load_balancer|
  if load_balancer.id == domain
    lb = load_balancer
    STDERR.puts "Got lb: "
    ap lb
  end
end

if lb == nil
  availability_zones = ['us-east-1a']
  lb = api.load_balancers.create(:id => domain.gsub(/[^a-zA-Z0-9]/, ''),
    :availability_zones => availability_zones,
    'ListenerDescriptions' => [{
      'Listener' => {
        'Protocol'         => 'HTTPS',
        'LoadBalancerPort' => 443,
        'InstancePort'     => 80,
        'InstanceProtocol' => 'HTTP',
        'SSLCertificateId' => arn
      }
  }])
end

server = JSON.parse(File.read('server.json'))

lb.register_instances(server['id'])
