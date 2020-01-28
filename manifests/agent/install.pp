# hm_ambari::agent::install
#
# Manage the installation for ambari agent
#
# @summary Ambari agent install handler
#
#
class hm_ambari::agent::install {
    $package_ensure = $hm_ambari::agent::package_ensure

    package { 'ambari-agent':
        ensure => $package_ensure,
    }
}