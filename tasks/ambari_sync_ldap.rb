#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def ambari_sync_ldap(group_path, admin_user, admin_password)
  cmd_string = 'ambari-server sync-ldap'
  cmd_string << " --groups=#{group_path}" unless group_path.nil?
  cmd_string << " --ldap-sync-admin-name=#{admin_user}" unless admin_user.nil?
  cmd_string << " --ldap-sync-admin-password=#{admin_password}" unless admin_password.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
group_path = params['group_path']
admin_user = params.fetch('admin_user', 'admin')
admin_password = params['admin_password']

begin
  result = ambari_sync_ldap(group_path, admin_user, admin_password)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
