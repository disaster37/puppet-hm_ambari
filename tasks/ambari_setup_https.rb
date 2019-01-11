#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def ambari_setup_https(api_ssl_port, pem_password, cert_path, key_path, cert_alias)
  cmd_string = 'ambari-server setup-security --security-option="setup-https"'
  cmd_string << ' --api-ssl=true'
  cmd_string << " --api-ssl-port=#{api_ssl_port}" unless api_ssl_port.nil?
  cmd_string << " --pem-password=#{pem_password}"
  cmd_string << " --import-cert-path=#{cert_path}" unless cert_path.nil?
  cmd_string << " --import-key-path=#{key_path}" unless key_path.nil?
  cmd_string << " --import-cert-alias=#{cert_alias}" unless cert_alias.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
api_ssl_port = params.fetch('api_ssl_port', 8443)
pem_password = params['pem_password']
cert_path = params['cert_path']
key_path = params['key_path']
cert_alias = params.fetch('cert_alias', 'ambari')

begin
  result = ambari_setup_https(api_ssl_port, pem_password, cert_path, key_path, cert_alias)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
