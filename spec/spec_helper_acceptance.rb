ENV['DOCKER_BUILDARGS'] = 'http_proxy=' + ENV['http_proxy'] + ' https_proxy=' + ENV['https_proxy']
ENV['BEAKER_PUPPET_AGENT_VERSION'] = '5.3.5'
ENV['BEAKER_PUPPET_COLLECTION'] = 'puppet5'

require 'beaker-pe'
require 'beaker-puppet'
require 'puppet'
# require 'beaker-hiera'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'beaker-task_helper'

run_puppet_install_helper_on(hosts)
install_bolt_on(hosts) unless pe_install?
# Disable because not work with proxy
# install_module_dependencies
# install_module

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  hosts.each do |host|
    on host, puppet('module', 'install', 'puppetlabs/stdlib'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppet-wget'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-inifile'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-java'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppet-archive'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-java_ks'), acceptable_exit_codes: [0, 1]
  end
end
