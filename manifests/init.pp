class hm_ambari(
    String                      $ambari_version             = $hm_ambari::params::ambari_version,
    Boolean                     $manage_repo                = $hm_ambari::params::manage_repo,
    Boolean                     $manage_java                = $hm_ambari::params::manage_java,
    Enum['absent', 'present']   $global_resources_ensure    = $hm_ambari::params::global_resources_ensure,
    Optional[String]            $service_provider           = $hm_ambari::params::service_provider,
) inherits hm_ambari::params {

    include ::stdlib

    # Check if supported OS
    if ($::kernel != 'Linux') and ($::osfamily != 'RedHat') {
        fail('Only Centos/Redhat is supported')
    }

    if $manage_repo == true {
        require ::hm_ambari::repo
    }

    if $manage_java == true {
        require ::hm_ambari::java
    }
}