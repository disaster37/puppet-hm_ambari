#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def ambari_setup_truststore(truststore_type, truststore_path, truststore_password, truststore_reconfigure)
  cmd_string = 'ambari-server setup-security --security-option="setup-truststore"'
  cmd_string << " --truststore-type=#{truststore_type}" unless truststore_type.nil?
  cmd_string << " --truststore-path=#{truststore_path}" unless truststore_path.nil?
  cmd_string << " --truststore-password=#{truststore_password}" unless truststore_password.nil?
  cmd_string << ' --truststore-reconfigure' unless truststore_reconfigure.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
truststore_type = params.fetch('truststore_type', 'jks')
truststore_path = params['truststore_path']
truststore_password = params['truststore_password']
truststore_reconfigure = params.fetch('truststore_reconfigure', true)

begin
  result = ambari_setup_truststore(truststore_type, truststore_path, truststore_password, truststore_reconfigure)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
