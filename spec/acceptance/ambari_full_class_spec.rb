require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'ambari server class:' do
  describe 'Deploy ambari server and ambari agent' do
    it 'run successfully' do
      pp = <<-EOS
        class { 'hm_ambari::server':
        }
        class { 'hm_ambari::agent':
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end
  end
end
