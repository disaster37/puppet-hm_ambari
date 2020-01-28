# hm_ambari::server::setup
#
# Manage the setup to lauch task
#
# @summary Ambari server setup handler
#
class hm_ambari::server::setup {
    $ambari_cli_version = $hm_ambari::server::ambari_cli_version
    $directory_ensure   = $hm_ambari::server::directory_ensure
    $file_ensure        = $hm_ambari::server::file_ensure
    $install_ambari_cli = $hm_ambari::server::install_ambari_cli
    $hdp_privileges     = $hm_ambari::server::hdp_privileges
    $hdp_repositories   = $hm_ambari::server::hdp_repositories
    $hdp_blueprint      = $hm_ambari::server::hdp_blueprint
    $hdp_hosts_template = $hm_ambari::server::hdp_hosts_template


    File {
        owner => 'root',
        group => 'root',
        mode =>  '0770'
    }

    if $install_ambari_cli == true {
        # Add ambari_cli
        if $file_ensure != 'absent' {
            include 'archive'
            archive { '/usr/bin/ambari-cli_linux_amd64':
              ensure => 'present',
              source => "https://github.com/disaster37/go-ambari-rest/releases/download/${ambari_cli_version}/ambari-cli_linux_amd64",
              user   => 'root',
            }
            file { '/usr/bin/ambari-cli_linux_amd64':
                ensure  => 'present',
                mode    => '0755',
                require => Archive['/usr/bin/ambari-cli_linux_amd64']
            }
        }
        else {
            file { '/usr/bin/ambari-cli_linux_amd64':
                ensure => 'absent'
            }
        }

        # Store hdp files
        file {'/etc/ambari-server/conf/api':
            ensure => $directory_ensure
        }

        # Create hdp privilege file to call task
        if $hdp_privileges != {} {
            file { '/etc/ambari-server/conf/api/privileges.json':
                ensure  => $file_ensure,
                content => template('hm_ambari/privileges.json.erb'),
            }
        }

        # Create hdp repository file to call task
        if $hdp_repositories != {} {
            file { '/etc/ambari-server/conf/api/repositories.json':
                ensure  => $file_ensure,
                content => template('hm_ambari/repositories.json.erb'),
            }
        }

        # Create Blueprint file
        if $hdp_blueprint != {} {
            file { '/etc/ambari-server/conf/api/blueprint.json':
                ensure  => $file_ensure,
                content => template('hm_ambari/blueprint.json.erb'),
            }
        }

        # Create host template file
        if $hdp_hosts_template != {} {
            file { '/etc/ambari-server/conf/api/hoststemplate.json':
                ensure  => $file_ensure,
                content => template('hm_ambari/hoststemplate.json.erb'),
            }
        }
    }
}