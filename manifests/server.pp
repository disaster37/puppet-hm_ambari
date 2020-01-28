# hm_ambari::server
#
# Ambari server
#
# @summary Ambari server
#
# @example
#   class {'hm_ambari::server':
#   }
#
# @param service_ensure
#   Start or stop service
#   Default value is set to `running`
#
# @param service_enable
#    Enable or disable service
#    Default value is set to `true`
#
# @param package_ensure
#   Set the package version
#   Default value is set to `present`
#
# @param ambari_server_settings
#   Set custom settings on ambari server config file
#   Default value is set to `{}`
#
# @param server_agent_ssl
#   Encrypt communication between agent and server
#   Default value is set to `false`
#
# @param disable_python_security
#   Disable secrutity on python. It's needed to use some scripts provided with Ambari
#   Default value is set to `true`
#
# @param ambari_cli_version
#   Set the version to ambari cli version to use when call with Ambari API
#   Default value is set to `1.0.4-2`
#
# @param install_ambari_cli
#   Install the ambari cli to call with Ambari API
#   Default value is set to `true`
#
# @param hdp_privileges
#   Create HDP privilege template file that you can use with task
#   Default value is set to `{}`
#
# @param hdp_repositories
#   Create HDP repository template file that you can use with task
#   Default value is set to `{}`
#
# @param hdp_blueprint
#   Create HDP blueprint template file that you can use with task
#   Default value is set to `{}`
#
# @param hdp_hosts_template
#   Create HDP host template file that you can use with task
#   Default value is set to `{}`
class hm_ambari::server(
  Stdlib::Ensure::Service                       $service_ensure,
  Boolean                                       $service_enable,
  String                                        $package_ensure,
  Hash[String, Hash]                            $ambari_server_settings,
  Boolean                                       $server_agent_ssl,
  Boolean                                       $disable_python_security,
  String                                        $ambari_cli_version,
  Boolean                                       $install_ambari_cli,
  Hash                                          $hdp_privileges,
  Hash                                          $hdp_repositories,
  Hash                                          $hdp_blueprint,
  Hash                                          $hdp_hosts_template,
){

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