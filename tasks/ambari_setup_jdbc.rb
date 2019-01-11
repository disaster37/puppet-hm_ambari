#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def ambari_setup_jdbc(jdbc_driver_path, jdbc_db)
  cmd_string = 'ambari-server setup'
  cmd_string << " --jdbc-driver=#{jdbc_driver_path}" unless jdbc_driver_path.nil?
  cmd_string << " --jdbc-db=#{jdbc_db}" unless jdbc_db.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)

  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
jdbc_driver_path = params['jdbc_driver_path']
jdbc_db = params['jdbc_db']

begin
  result = ambari_setup_jdbc(jdbc_driver_path, jdbc_db)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
