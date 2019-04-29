class hm_ambari::java {

    class { '::java':
        distribution => 'jdk',
        version      => 'latest',
    }

}