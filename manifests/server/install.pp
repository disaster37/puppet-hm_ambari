class hm_ambari::server::install {
    $package_ensure = $hm_ambari::server::package_ensure

    package { 'ambari-server':
        ensure  => $package_ensure,
    }
}