#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def hpd_manage_repository(ambari_url, ambari_login, ambari_password, use_spacewalk, repository_file)
  cmd_string = 'ambari-cli_linux_amd64'
  cmd_string << " --ambari-url #{ambari_url}" unless ambari_url.nil?
  cmd_string << " --ambari-login #{ambari_login}" unless ambari_login.nil?
  cmd_string << " --ambari-password #{ambari_password}" unless ambari_password.nil?
  cmd_string << ' create-or-update-repository'
  cmd_string << ' --use-spacewalk' if use_spacewalk
  cmd_string << " --repository-file #{repository_file}" unless repository_file.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
ambari_url = params.fetch('ambari_url', 'http://localhost:8080/api/v1')
ambari_login = params.fetch('ambari_login', 'admin')
ambari_password = params.fetch('ambari_password', 'admin')
use_spacewalk = params.fetch('use_spacewalk', false)
repository_file = params['repository_file']

begin
  result = hpd_manage_repository(ambari_url, ambari_login, ambari_password, use_spacewalk, repository_file)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
