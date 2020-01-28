# hm_ambari::agent
#
# Ambari agent
#
# @summary Ambari agent
#
# @example
#   class {'hm_ambari::agent':
#     ambari_server => 'ambari-server.domain.com',
#   }
#
# @param service_ensure
#   Start or stop service
#   Default value is set to `running`

# @param service_enable
#    Enable or disable service
#    Default value is set to `true`
#
# @param ambari_server_port
#    Set the ambari server port
#    Default value is set to `8440`
#
# @param ambari_server_secure_port
#   Set the ambari server secure port
#   Default value is set to `8441`
#
# @param ambari_server
#   Set the ambari serveur host name to connect on it
#   Default value is set to `localhost`
#
# @param package_ensure
#   Set the package version
#   Default value is set to `present`
#
# @param ambari_agent_settings
#   Set custom settings on ambari agent config file
#   Default value is set to `{}`
#
# @param ambari_agent_alias
#   Set the alias name for ambari agent
#   Default value is set to `undef`
#
class hm_ambari::agent(
  Stdlib::Ensure::Service                       $service_ensure,
  Boolean                                       $service_enable,
  Stdlib::Port                                  $ambari_server_port,
  Stdlib::Port                                  $ambari_server_secure_port,
  Stdlib::Host                                  $ambari_server,
  String                                        $package_ensure,
  Hash[String, Hash]                            $ambari_agent_settings,
  Optional[String]                              $ambari_agent_alias,
) {


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
