#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def hpd_manage_permission(ambari_url, ambari_login, ambari_password, privilege_file)
  cmd_string = 'ambari-cli_linux_amd64'
  cmd_string << " --ambari-url #{ambari_url}" unless ambari_url.nil?
  cmd_string << " --ambari-login #{ambari_login}" unless ambari_login.nil?
  cmd_string << " --ambari-password #{ambari_password}" unless ambari_password.nil?
  cmd_string << ' create-or-update-privileges'
  cmd_string << " --privileges-file #{privilege_file}" unless privilege_file.nil?

  puts cmd_string

  stdout, stderr, status = Open3.capture3(cmd_string)
  stdout.strip
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
ambari_url = params.fetch('ambari_url', 'http://localhost:8080/api/v1')
ambari_login = params.fetch('ambari_login', 'admin')
ambari_password = params.fetch('ambari_password', 'admin')
privilege_file = params['privilege_file']

begin
  result = hpd_manage_permission(ambari_url, ambari_login, ambari_password, privilege_file)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
