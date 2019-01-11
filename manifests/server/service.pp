class hm_ambari::server::service {
    $real_service_ensure = $hm_ambari::server::real_service_ensure
    $service_enable = $hm_ambari::server::service_enable
    $service_provider = $hm_ambari::service_provider

    service { 'ambari-server':
        ensure   => $real_service_ensure,
        enable   => $service_enable,
        provider => $service_provider,
    }
}