#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def hpd_add_node(ambari_url, ambari_login, ambari_password, cluster_name, blueprint_name, hostname, role, rack)
  cmd_string = 'ambari-cli_linux_amd64'
  cmd_string << " --ambari-url #{ambari_url}" unless ambari_url.nil?
  cmd_string << " --ambari-login #{ambari_login}" unless ambari_login.nil?
  cmd_string << " --ambari-password #{ambari_password}" unless ambari_password.nil?
  cmd_string << ' add-host-in-cluster'
  cmd_string << " --cluster-name #{cluster_name}" unless cluster_name.nil?
  cmd_string << " --blueprint-name #{blueprint_name}" unless blueprint_name.nil?
  cmd_string << " --hostname #{hostname}" unless hostname.nil?
  cmd_string << " --role #{role}" unless role.nil?
  cmd_string << " --rack #{rack}" unless rack.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
ambari_url = params.fetch('ambari_url', 'http://localhost:8080/api/v1')
ambari_login = params.fetch('ambari_login', 'admin')
ambari_password = params.fetch('ambari_password', 'admin')
cluster_name = params['cluster_name']
blueprint_name = params['blueprint_name']
hostname = params['hostname']
role = params['role']
rack = params['rack']

begin
  result = hpd_add_node(ambari_url, ambari_login, ambari_password, cluster_name, blueprint_name, hostname, role, rack)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
