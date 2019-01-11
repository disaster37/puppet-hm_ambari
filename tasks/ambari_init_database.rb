#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def ambari_init_database(db_type, db_name, db_host, db_port, db_user, db_password)
  case db_type
  when 'mysql'
    cmd_string = 'mysql'
    cmd_string << " --host #{db_host}" unless db_host.nil?
    cmd_string << " --port #{db_port}" unless db_port.nil?
    cmd_string << " --user #{db_user}" unless db_user.nil?
    cmd_string << " --password #{db_password}" unless db_password.nil?
    cmd_string << " --database #{db_name}" unless db_name.nil?
    cmd_string << ' < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql'

  when 'postgres'
    cmd_string = "PGPASSWORD=#{db_password} " unless db_password.nil?
    cmd_string << 'psql'
    cmd_string << " -h #{db_host}" unless db_host.nil?
    cmd_string << " -p #{db_port}" unless db_port.nil?
    cmd_string << " -U #{db_user}" unless db_user.nil?
    cmd_string << " -d #{db_name}" unless db_name.nil?
    cmd_string << ' -f /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql'
  else
    raise Puppet::Error, 'We support only mysql and postgresql db_type'
  end

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
db_type = params['db_type']
db_host = params['db_host']
db_name = params['db_name']
db_port = params.fetch('db_port', '5432')
db_user = params['db_user']
db_password = params['db_password']

begin
  result = ambari_init_database(db_type, db_name, db_host, db_port, db_user, db_password)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
