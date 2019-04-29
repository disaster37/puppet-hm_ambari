class hm_ambari::agent::config {

    $ambari_agent_settings      = $hm_ambari::agent::ambari_agent_settings
    $ambari_server              = $hm_ambari::agent::ambari_server
    $ambari_server_port         = $hm_ambari::agent::ambari_server_port
    $ambari_server_secure_port  = $hm_ambari::agent::ambari_server_secure_port
    $ambari_agent_alias         = $hm_ambari::agent::ambari_agent_alias
    $file_ensure                = $hm_ambari::agent::file_ensure


    # Ambari settings
    file { '/etc/ambari-agent/conf/ambari-agent.ini':
        ensure => $file_ensure,
    }
    $defaults = {
        path              => '/etc/ambari-agent/conf/ambari-agent.ini',
        key_val_separator => '=',
    }

    $agent_settings = {
        'server' => {
            'hostname'   => $ambari_server,
            'url_port'   => $ambari_server_port,
            'secured_url_port' => $ambari_server_secure_port,
        },
        'security' => {
          'force_https_protocol' => 'PROTOCOL_TLSv1_2'
        },
    }

    # Ambari alias name
    if $ambari_agent_alias != undef {
        file { '/var/lib/ambari-agent/hostname.sh':
            ensure  => $file_ensure,
            mode    => '0755',
            content => "#!/bin/sh\necho '${ambari_agent_alias}'",
        }

        $alias_settings = {
            'agent' => {
                'hostname_script' => '/var/lib/ambari-agent/hostname.sh',
            },
        }
    }
    else {
        $alias_settings = {}
    }

    $settings = merge($alias_settings, $agent_settings, $ambari_agent_settings)
    create_ini_settings($settings, $defaults)
}