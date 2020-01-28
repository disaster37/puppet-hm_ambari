# hm_ambari::server::config
#
# Manage the config file for ambari server
#
# @summary Ambari server config file handler
#
class hm_ambari::server::config{
    $file_ensure            = $hm_ambari::server::file_ensure
    $server_agent_ssl       = $hm_ambari::server::server_agent_ssl
    $ambari_server_settings = $hm_ambari::server::ambari_server_settings

    # Ambari settings
    file { '/etc/ambari-server/conf/ambari.properties':
        ensure => $file_ensure,
    }
    $defaults = {
        path              => '/etc/ambari-server/conf/ambari.properties',
        key_val_separator => '=',
    }


    $server_settings = {
        '' => {
            'security.server.two_way_ssl' => $server_agent_ssl,
        }
    }

    $settings = merge($server_settings, $ambari_server_settings)
    create_ini_settings($settings, $defaults)
}