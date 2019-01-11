#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'
require 'open-uri'
require 'fileutils'
require 'uri'
require 'net/http'

def ambari_add_mpack(mpack_file, mpack_url, proxy_url, proxy_user, proxy_password)
  if mpack_url.nil? && mpack_file.nil?
    raise Puppet::Error, 'You must provide mpack_file or mpack_url, or the two.'
  end

  unless mpack_url.nil?
    uri = URI.parse(mpack_url)
    basename = File.basename(uri.path)
    mpack_file = "/tmp/#{basename}" if mpack_file.nil?

    download(mpack_url, mpack_file, proxy_url, proxy_user, proxy_password)
  end

  cmd_string = 'ambari-server install-mpack'
  cmd_string << " --mpack=#{mpack_file}" unless mpack_file.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

def download(url, path, proxy_url, proxy_user, proxy_password)
  case io = open(url, proxy_http_basic_authentication: [proxy_url, proxy_user, proxy_password])
  when StringIO then File.open(path, 'w') { |f| f.write(io) }
  when Tempfile
    io.close
    FileUtils.mv(io.path, path)
  end
end

params = JSON.parse(STDIN.read)
mpack_file = params['mpack_file']
mpack_url = params['mpack_url']
proxy_url = params['proxy_url']
proxy_user = params['proxy_user']
proxy_password = params['proxy_password']

begin
  result = ambari_add_mpack(mpack_file, mpack_url, proxy_url, proxy_user, proxy_password)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
