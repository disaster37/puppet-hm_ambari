# hm_ambari::agent::service
#
# Manage the service for ambari agent
#
# @summary Ambari agent service handler
#
#
class hm_ambari::agent::service {

    $real_service_ensure    = $hm_ambari::agent::real_service_ensure
    $service_enable         = $hm_ambari::agent::service_enable
    $service_provider       = $hm_ambari::service_provider

    service { 'ambari-agent':
        ensure   => $real_service_ensure,
        enable   => $service_enable,
        provider => $service_provider,
    }


}