class hm_ambari::agent(
  Variant[Boolean, Enum['stopped', 'running']] $service_ensure = $hm_ambari::params::agent_service_ensure,
  Boolean $service_enable = $hm_ambari::params::agent_service_enable,
  String $ambari_server_port = $hm_ambari::params::ambari_server_port,
  String $ambari_server_secure_port = $hm_ambari::params::ambari_server_secure_port,
  String $ambari_server= $hm_ambari::params::ambari_server,
  Optional[String] $ambari_agent_alias = $hm_ambari::params::ambari_agent_alias,
  Enum['present', 'absent'] $package_ensure = $hm_ambari::params::agent_package_ensure,
  Hash[String, Hash] $ambari_agent_settings = $hm_ambari::params::ambari_agent_settings,
) inherits hm_ambari::params {


    include hm_ambari

    if $package_ensure == 'absent' {
        $real_service_ensure = 'stopped'
        $file_ensure = 'absent'
        $directory_ensure = 'absent'
    } else {
        $file_ensure = 'file'
        $directory_ensure = 'directory'
        $real_service_ensure = $service_ensure
    }

    class { 'hm_ambari::agent::install':
        notify => Class['hm_ambari::agent::service']
    }

    class { 'hm_ambari::agent::config':
        notify => Class['hm_ambari::agent::service']
    }

    class { 'hm_ambari::agent::service': }

    if $package_ensure == 'absent' {
        anchor { 'hm_ambari::agent::begin': }
        -> Class['hm_ambari::agent::service']
        -> Class['hm_ambari::agent::config']
        -> Class['hm_ambari::agent::install']
        -> Class['hm_ambari']
        -> anchor { 'hm_ambari::agent::end': }
    } else {
        anchor { 'hm_ambari::agent::begin': }
        -> Class['hm_ambari']
        -> Class['hm_ambari::agent::install']
        -> Class['hm_ambari::agent::config']
        -> Class['hm_ambari::agent::service']
        -> anchor { 'hm_ambari::agent::end': }
    }
}
