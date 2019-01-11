#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'open3'
require 'puppet'

def ambari_setup(java_home, db_type, db_host, db_name, db_port, db_user, db_password)
  cmd_string = 'ambari-server setup --silent'
  cmd_string << " --java-home=#{java_home}" unless java_home.nil?
  cmd_string << " --database=#{db_type}" unless db_type.nil?
  cmd_string << " --databasehost=#{db_host}" unless db_host.nil?
  cmd_string << " --databaseport=#{db_port}" unless db_port.nil?
  cmd_string << " --databasename=#{db_name}" unless db_name.nil?
  cmd_string << " --databaseusername=#{db_user}" unless db_user.nil?
  cmd_string << " --databasepassword=#{db_password}" unless db_password.nil?
  cmd_string << ' --enable-lzo-under-gpl-license'

  stdout, stderr, status = Open3.capture3(cmd_string)

  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
java_home = params['java_home']
db_type = params['db_type']
db_host = params['db_host']
db_name = params['db_name']
db_port = params.fetch('db_port', 5432)
db_user = params['db_user']
db_password = params['db_password']

begin
  result = ambari_setup(java_home, db_type, db_host, db_name, db_port, db_user, db_password)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
