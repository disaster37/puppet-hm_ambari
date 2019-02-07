plan hm_ambari::ambari_setup (
    TargetSpec $nodes,
    String $java_home = '/usr/lib/jvm/java',
    String $db_type,
    String $db_host,
    Integer $db_port,
    String $db_name,
    String $db_user,
    String $db_password,
    String $master_key,
    String $jdbc_driver_path,
    Boolean $enable_https = true,
    Optional[String] $cert_key_path = undef,
    Optional[String] $cert_crt_path = undef,
    Optional[Integer] $api_ssl_port = 8443,
    Optional[String] $cert_alias = 'ambari',
    Optional[String] $truststore_path = undef,
    Array[String] $mpacks_url = [],
    Optional[String] $proxy_url = undef,
    Optional[String] $proxy_user = undef,
    Optional[String] $proxy_password = undef,
    Boolean $enable_ldap = true,
    Optional[String] $ldap_url = undef,
    Optional[String] $ldap_secondary_url = undef,
    Optional[Enum['true', 'false']] $ldap_ssl = 'true',
    Optional[String] $ldap_type = 'AD',
    Optional[String] $ldap_user_class = 'person',
    Optional[String] $ldap_user_attr = 'sAMAccountName',
    Optional[String] $ldap_group_class = 'group',
    Optional[String] $ldap_group_attr = 'cn',
    Optional[String] $ldap_member_attr = 'member',
    Optional[String] $ldap_dn = 'distunguishedName',
    Optional[String] $ldap_base_dn = undef,
    Optional[String] $ldap_referral = 'follow',
    Optional[Enum['true', 'false']] $ldap_bind_anonym = 'false',
    Optional[String] $ldap_manager_dn = undef,
    Optional[String] $ldap_manager_password = undef,
    Optional[Boolean] $ldap_save_settings = true,
    Optional[String] $ldap_collision = 'convert',
    Optional[Boolean] $ldap_lowercase = true,
    Optional[String] $admin_user = 'admin',
    Optional[String] $admin_password = undef
) {

    # Stop Ambari server
    $r0 = run_task(
        'service',
        $nodes,
        name    => 'ambari-server',
        action  => 'stop'
    )
    $r0.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} returned a value: ${result.value}")
        } else {
            notice("${node} errored with a message: ${result.error.message}")
        }
    }

    # Setup Ambari server
    $r1 = run_task(
        'hm_ambari::ambari_setup',
        $nodes,
        java_home   => $java_home,
        db_type     => $db_type,
        db_host     => $db_host,
        db_name     => $db_name,
        db_user     => $db_user,
        db_password => $db_password,
        db_port     => $db_port
    )
    $r1.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} returned a value: ${result.value}")
        } else {
            notice("${node} errored with a message: ${result.error.message}")
        }
    }
    
    # Init database
    $r2 = run_task(
        'hm_ambari::ambari_init_database',
        $nodes,
        db_type     => $db_type,
        db_host     => $db_host,
        db_name     => $db_name,
        db_user     => $db_user,
        db_password => $db_password,
        db_port     => $db_port
    )
    $r2.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} returned a value: ${result.value}")
        } else {
            notice("${node} errored with a message: ${result.error.message}")
        }
    }
    
    # Encrypt password in setting file
    $r3 = run_task(
        'hm_ambari::ambari_encrypt_password',
        $nodes,
        master_key => $master_key
    )
    $r3.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} returned a value: ${result.value}")
        } else {
            notice("${node} errored with a message: ${result.error.message}")
        }
    }
    
    # Setup JDBC driver
    $r4 = run_task(
        'hm_ambari::ambari_setup_jdbc',
        $nodes,
        jdbc_driver_path    => $jdbc_driver_path,
        jdbc_db             => $db_type
    )
    $r4.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} returned a value: ${result.value}")
        } else {
            notice("${node} errored with a message: ${result.error.message}")
        }
    }
    
    # Setup HTTPS
    if $enable_https == true {
    
        # Enable HTTPS
        $r_setup_https = run_task(
            'hm_ambari::ambari_setup_https',
            $nodes,
            api_ssl_port    => $api_ssl_port,
            cert_path       => $cert_crt_path,
            key_path        => $cert_key_path,
            cert_alias      => $cert_alias,
        )
        $r_setup_https.each |$result| {
            $node = $result.target.name
            if $result.ok {
                notice("${node} returned a value: ${result.value}")
            } else {
                notice("${node} errored with a message: ${result.error.message}")
            }
        }
    }
    
    # Setup truststore
    if $truststore_path != undef {
        $r_setup_truststore = run_task(
            'hm_ambari::ambari_setup_truststore',
            $nodes,
            truststore_type         => 'jks',
            truststore_path         => '/etc/ambari-server/truststore.jks',
            truststore_password     => 'ambari',
            truststore_reconfigure  => true,
        )
        $r_setup_truststore.each |$result| {
            $node = $result.target.name
            if $result.ok {
                notice("${node} returned a value: ${result.value}")
            } else {
                notice("${node} errored with a message: ${result.error.message}")
            }
        }
    }
    
    # Add mpacks Mpack
    $mpacks_url.each |$mpack_url| {
        $r_setup_mpack = run_task(
            'hm_ambari::ambari_add_mpack',
            $nodes,
            mpack_url       => $mpack_url,
            proxy_url       => $proxy_url,
            proxy_user      => $proxy_user,
            proxy_password  => $proxy_password
        )
        $r_setup_mpack.each |$result| {
            $node = $result.target.name
            if $result.ok {
                notice("${node} returned a value: ${result.value}")
            } else {
                notice("${node} errored with a message: ${result.error.message}")
            }
        }
    }
    
    # Start Ambari server
    $r_start_service = run_task(
        'service',
        $nodes,
        name => 'ambari-server',
        action => 'start'
    )
    $r_start_service.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} returned a value: ${result.value}")
        } else {
            notice("${node} errored with a message: ${result.error.message}")
        }
    }
    
    # Setup LDAP
    if $enable_ldap == true {
        $r_setup_ldap = run_task(
            'hm_ambari::ambari_setup_ldap',
            $nodes,
            ldap_url                => $ldap_url,
            ldap_secondary_url      => $ldap_secondary_url,
            ldap_ssl                => $ldap_ssl,
            ldap_type               => $ldap_type,
            ldap_user_class         => $ldap_user_class,
            ldap_user_attr          => $ldap_user_attr,
            ldap_group_class        => $ldap_group_class,
            ldap_group_attr         => $ldap_group_attr,
            ldap_member_attr        => $ldap_member_attr,
            ldap_dn                 => $ldap_dn,
            ldap_base_dn            => $ldap_base_dn,
            ldap_referral           => $ldap_referral,
            ldap_bind_anonym        => $ldap_bind_anonym,
            ldap_manager_dn         => $ldap_manager_dn,
            ldap_manager_password   => $ldap_manager_password,
            ldap_save_settings      => $ldap_save_settings,
            ldap_collision          => $ldap_collision,
            ldap_lowercase          => $ldap_lowercase,
            admin_user              => $admin_user,
            admin_password          => $admin_password,
            
        )
        $r_setup_ldap.each |$result| {
            $node = $result.target.name
            if $result.ok {
                notice("${node} returned a value: ${result.value}")
            } else {
                notice("${node} errored with a message: ${result.error.message}")
            }
        }
    }
    
    
    notice('Don\'t forget to put `hm_ambari::server::$service_ensure = \'running\'`')
    

}