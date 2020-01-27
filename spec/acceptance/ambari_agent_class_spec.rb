require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'ambari agent class:' do
  describe 'Deploy ambari agent' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'hm_ambari::agent':
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end

    describe package('java-1.8.0-openjdk-devel') do
      it { is_expected.to be_installed }
    end
    describe package('ambari-agent') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/yum.repos.d/ambari.repo') do
      it { is_expected.to be_file }
    end

    describe file('/etc/ambari-agent/conf/ambari-agent.ini') do
      it { is_expected.to contain 'PROTOCOL_TLSv1_2' }
    end

    describe service('ambari-agent') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
