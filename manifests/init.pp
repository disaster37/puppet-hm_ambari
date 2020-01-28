# hm_ambari
#
# Ambari main class
#
# @summary Ambari Core
#
# @example
#   class {'hm_ambari:
#   }
#
# @param ambari_version
#   Set the ambari version to use
#   Default value is set to `2.7.3.0`

# @param manage_repo
#    It manage yum repository or not
#    Default value is set to `true`
#
# @param manage_java
#    It manage Java or not
#    Default value is set to `true`
#
# @param global_resources_ensure
#   The global resource ensure.
#   It's needed to clean when remove module
#   Default value is set to `present`
#
# @param service_provider
#   The service provider to use
#   Default value is set to `systemd`
class hm_ambari(
    String                      $ambari_version,
    Boolean                     $manage_repo,
    Boolean                     $manage_java,
    Enum['absent', 'present']   $global_resources_ensure,
    Optional[String]            $service_provider,
) {

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