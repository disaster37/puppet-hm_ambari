class hm_ambari::agent::install {
    $package_ensure = $hm_ambari::agent::package_ensure

    package { 'ambari-agent':
        ensure => $package_ensure,
    }
}