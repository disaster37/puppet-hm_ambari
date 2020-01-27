plan hm_ambari::deploy_hdp (
    TargetSpec          $nodes,
    String              $ambari_url                             = 'https://localhost:8443/api/v1',
    String              $ambari_login                           = 'admin',
    String              $ambari_password                        = 'admin',
    Boolean             $use_spacewalk                          = false,
    String              $cluster_name,
    String              $repository_file,
    String              $blueprint_file,
    String              $host_template_file,
    Optional[String]    $privilege_file                         = undef,
    Boolean             $enable_kerberos                        = false,
    Optional[String]    $kdc_type                               = undef,
    Optional[Boolean]   $disable_manage_identities              = undef,
    Optional[String]    $kdc_hosts                              = undef,
    Optional[String]    $realm                                  = undef,
    Optional[String]    $ldap_url                               = undef,
    Optional[String]    $container_dn                           = undef,
    Optional[String]    $domains                                = undef,
    Optional[String]    $admin_server_host                      = undef,
    Optional[String]    $principal_name                         = undef,
    Optional[String]    $principal_password                     = undef,
    Optional[Boolean]   $persist_credential                     = undef,
    Optional[Boolean]   $disable_install_packages               = undef,
    Optional[String]    $executable_search_paths                = undef,
    Optional[String]    $encryption_type                        = undef,
    Optional[Integer]   $password_length                        = undef,
    Optional[Integer]   $password_min_lowercase_letters         = undef,
    Optional[Integer]   $password_min_uppercase_letters         = undef,
    Optional[Integer]   $password_min_digits                    = undef,
    Optional[Integer]   $password_min_punctuation               = undef,
    Optional[Integer]   $password_min_whitespace                = undef,
    Optional[String]    $check_principal_name                   = undef,
    Optional[Boolean]   $enable_case_insensitive_username_rules = undef,
    Optional[Boolean]   $disable_manage_auth_to_local           = undef,
    Optional[Boolean]   $disable_create_ambari_principal        = undef,
    Optional[String]    $master_kdc_host                        = undef,
    Optional[String]    $preconfigure_services                  = undef,
    Optional[String]    $ad_create_attributes_template          = undef,
    Optional[Boolean]   $disable_manage_krb5_conf               = undef,
    Optional[String]    $krb5_conf_directory                    = undef,
    Optional[String]    $krb5_conf_template                     = undef
) {

    # Add HDP repository
    $r_manage_repository = run_task(
        'hm_ambari::hdp_manage_repository',
        $nodes,
        _catch_errors   => true,
        ambari_url      => $ambari_url,
        ambari_login    => $ambari_login,
        ambari_password => $ambari_password,
        use_spacewalk   => $use_spacewalk,
        repository_file => $repository_file,
    )
    $r_manage_repository.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} successed with a value: ${result.message}")
        } else {
            err("${node} errored with a message: ${result.error.message}\n${result.message}")
        }
    }

    # Deploy HDP cluster with blueprint
    $r_deploy_cluster = run_task(
        'hm_ambari::hdp_deploy_cluster',
        $nodes,
        _catch_errors       => true,
        ambari_url          => $ambari_url,
        ambari_login        => $ambari_login,
        ambari_password     => $ambari_password,
        cluster_name        => $cluster_name,
        blueprint_file      => $blueprint_file,
        host_template_file  => $host_template_file,
    )
    $r_deploy_cluster.each |$result| {
        $node = $result.target.name
        if $result.ok {
            notice("${node} successed with a value: ${result.message}")
        } else {
            err("${node} errored with a message: ${result.error.message}\n${result.message}")
        }
    }

    # Manage privileges
    if $privilege_file != undef {
        $r_manage_privileges = run_task(
            'hm_ambari::hdp_manage_permission',
            $nodes,
            _catch_errors       => true,
            ambari_url          => $ambari_url,
            ambari_login        => $ambari_login,
            ambari_password     => $ambari_password,
            privilege_file      => $privilege_file,
        )
        $r_manage_privileges.each |$result| {
            $node = $result.target.name
            if $result.ok {
                notice("${node} successed with a value: ${result.message}")
            } else {
                err("${node} errored with a message: ${result.error.message}\n${result.message}")
            }
        }
    }

    # Enable kerberos
    if $enable_kerberos == true {
        $r_enable_kerberos = run_task(
            'hm_ambari::hdp_enable_kerberos',
            $nodes,
            _catch_errors                           => true,
            ambari_url                              => $ambari_url,
            ambari_login                            => $ambari_login,
            ambari_password                         => $ambari_password,
            cluster_name                            => $cluster_name,
            kdc_type                                => $kdc_type,
            disable_manage_identities               => $disable_manage_identities,
            kdc_hosts                               => $kdc_hosts,
            realm                                   => $realm,
            ldap_url                                => $ldap_url,
            container_dn                            => $container_dn,
            domains                                 => $domains,
            admin_server_host                       => $admin_server_host,
            principal_name                          => $principal_name,
            principal_password                      => $principal_password,
            persist_credential                      => $persist_credential,
            disable_install_packages                => $disable_install_packages,
            executable_search_paths                 => $executable_search_paths,
            encryption_type                         => $encryption_type,
            password_length                         => $password_length,
            password_min_lowercase_letters          => $password_min_lowercase_letters,
            password_min_uppercase_letters          => $password_min_uppercase_letters,
            password_min_digits                     => $password_min_digits,
            password_min_punctuation                => $password_min_punctuation,
            password_min_whitespace                 => $password_min_whitespace,
            check_principal_name                    => $check_principal_name,
            enable_case_insensitive_username_rules  => $enable_case_insensitive_username_rules,
            disable_manage_auth_to_local            => $disable_manage_auth_to_local,
            disable_create_ambari_principal         => $disable_create_ambari_principal,
            master_kdc_host                         => $master_kdc_host,
            preconfigure_services                   => $preconfigure_services,
            ad_create_attributes_template           => $ad_create_attributes_template,
            disable_manage_krb5_conf                => $disable_manage_krb5_conf,
            krb5_conf_directory                     => $krb5_conf_directory,
            krb5_conf_template                      => $krb5_conf_template,
        )
        $r_enable_kerberos.each |$result| {
            $node = $result.target.name
            if $result.ok {
                notice("${node} successed with a value: ${result.message}")
            } else {
                err("${node} errored with a message: ${result.error.message}\n${result.message}")
            }
        }
    }


    notice('HDP deployement is finished')


}