require 'spec_helper_acceptance'

describe 'basic tests:' do
  it 'make sure we have copied the module across' do
    shell("ls #{default['distmoduledir']}/hm_ambari/Rakefile", acceptable_exit_codes: 0)
  end
end
