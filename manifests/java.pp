# hm_ambari::java
#
# Manage the Java installation
#
# @summary Ambari Java handler
#
# @example
#   class {'hm_ambari::java:
#   }
#
class hm_ambari::java {

    class { '::java':
        distribution => 'jdk',
        version      => 'latest',
    }

}