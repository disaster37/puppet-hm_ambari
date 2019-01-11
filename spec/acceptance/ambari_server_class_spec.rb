require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'ambari server class:' do
  describe 'Deploy ambari server' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'hm_ambari::server':
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end

    describe package('java-1.8.0-openjdk-devel') do
      it { is_expected.to be_installed }
    end

    describe package('ambari-server') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/yum.repos.d/ambari.repo') do
      it { is_expected.to be_file }
    end
    describe file('/etc/ambari-server/conf/api') do
      it { is_expected.to be_directory }
    end
    describe file('/etc/python/cert-verification.cfg') do
      it { is_expected.to contain 'verify=disable' }
    end
    describe file('/etc/ambari-server/conf/ambari.properties') do
      it { is_expected.to be_file }
    end

    describe service('ambari-server') do
      it { is_expected.to be_enabled }
    end
  end

  describe 'Deploy ambari server, no more change' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'hm_ambari::server':

        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 0
    end
  end

  describe 'Remove ambari server' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'hm_ambari':
          global_resources_ensure => 'absent'
        }
        class { 'hm_ambari::server':
          package_ensure => 'absent',
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end

    describe package('ambari-server') do
      it { is_expected.not_to be_installed }
    end

    describe file('/etc/ambari-server/conf/api') do
      it { is_expected.not_to be_directory }
    end

    describe file('/etc/yum.repos.d/ambari.repo') do
      it { is_expected.not_to be_file }
    end

    describe service('ambari-server') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end

    describe port(8443) do
      it { is_expected.not_to be_listening }
    end
  end
end
