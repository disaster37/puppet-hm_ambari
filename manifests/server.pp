class hm_ambari::server(
  Variant[Boolean, Enum['stopped', 'running']]  $service_ensure             = $hm_ambari::params::server_service_ensure,
  Boolean                                       $service_enable             = $hm_ambari::params::server_service_enable,
  String                                        $package_ensure             = $hm_ambari::params::server_package_ensure,
  Hash[String, Hash]                            $ambari_server_settings     = $hm_ambari::params::ambari_server_settings,
  Boolean                                       $server_agent_ssl           = $hm_ambari::params::server_agent_ssl,
  Boolean                                       $disable_python_security    = $hm_ambari::params::disable_python_security,
  String                                        $ambari_cli_version         = $hm_ambari::params::ambari_cli_version,
  Boolean                                       $install_ambari_cli         = $hm_ambari::params::install_ambari_cli,
  Hash                                          $hdp_privileges             = $hm_ambari::params::hdp_privileges,
  Hash                                          $hdp_repositories           = $hm_ambari::params::hdp_repositories,
  Hash                                          $hdp_blueprint              = $hm_ambari::params::hdp_blueprint,
  Hash                                          $hdp_hosts_template         = $hm_ambari::params::hdp_hosts_template,

) inherits hm_ambari::params {

    if $package_ensure == 'absent' {
        $real_service_ensure    = 'stopped'
        $file_ensure            = 'absent'
        $directory_ensure       = 'absent'
    } else {
        $file_ensure            = 'file'
        $directory_ensure       = 'directory'
        $real_service_ensure    = $service_ensure
    }

    include ::hm_ambari

    if $disable_python_security == true {
        require ::hm_ambari::server::python
    }

    class { '::hm_ambari::server::setup':}

    class { '::hm_ambari::server::service': }

    if $package_ensure == 'absent' {
        class { '::hm_ambari::server::install': }
        class { '::hm_ambari::server::config': }
        anchor { 'hm_ambari::server::begin': }
        -> Class['hm_ambari::server::service']
        -> Class['hm_ambari::server::config']
        -> Class['hm_ambari::server::setup']
        -> Class['hm_ambari::server::install']
        -> Class['hm_ambari']
        -> anchor { 'hm_ambari::server::end': }
    } else {
        class { '::hm_ambari::server::install':
            notify => Class['hm_ambari::server::service']
        }

        class { '::hm_ambari::server::config':
            notify => Class['hm_ambari::server::service']
        }

        anchor { 'hm_ambari::server::begin': }
        -> Class['hm_ambari']
        -> Class['hm_ambari::server::install']
        -> Class['hm_ambari::server::config']
        -> Class['hm_ambari::server::setup']
        -> Class['hm_ambari::server::service']
        -> anchor { 'hm_ambari::server::end': }
    }
}