#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def ambari_encrypt_password(master_key, key_persist)
  cmd_string = 'ambari-server setup-security --security-option="encrypt-passwords"'
  cmd_string << " --master-key=#{master_key}" unless master_key.nil?
  cmd_string << " --master-key-persist=#{key_persist}" unless key_persist.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
master_key = params['master_key']
key_persist = params.fetch('key_persist', 'true')

begin
  result = ambari_encrypt_password(master_key, key_persist)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
