#!/usr/bin/env ruby

require 'fog'
require 'awesome_print'

# Fog.mock!

domain = ARGV.shift
cert_id = ARGV.shift

aws_credentials = YAML.load(File.open("creds.yml"))

api        = Fog::AWS::ELB.new(aws_credentials)
iam        = Fog::AWS::IAM.new(aws_credentials)
result = iam.list_server_certificates({'PathPrefix' => '/'})

result.body['Certificates'].each do |cert|
  ap cert
end

__END__

lb = api.load_balancers.create(:id => domain, 'ListenerDescriptions' => [{
    'Listener' => {
      'Protocol' => 'HTTPS',
      'LoadBalancerPort' => 443,
      'InstancePort' => 80,
      'InstanceProtocol' => 'HTTP',
      'SSLCertificateId' => cert_id
    }
}])

ap lb
