class hm_ambari::server::python {

    # Disable python security
    file_line { '/etc/python/cert-verification.cfg':
        ensure => 'present',
        path   => '/etc/python/cert-verification.cfg',
        line   => 'verify=disable',
        match  => '^verify=\w+',
    }
}