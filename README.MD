# Ambari

This module permit to deploy Ambari Server and Ambari Agent.
It's composed of standard module to install ambari and Java, and manage basic settings and services.
It's also composed of plan and task that permit to setup Ambari (database, encryption, JDBC driver, LDAP) and deploy HDP (with blueprint API).

## The module limitation

- This module only work with Redhat base OS >= 7
- Tested on Puppet 5.3.7
- Tested with Ambari 2.7.3 and HDP 2.6


## How to use module

You need to apply the `hm_ambari::agent` and `hm_ambari::server` on your nodes.

> on the first apply, you need to set `hm_ambari::server::$server_service_ensure = 'stopped'`.

Then execute the plan `hm_ambari::ambari_setup` with Bolt.
After that, you need to lauch the plan `hm_ambari::deploy_hdp` to deploy HDP cluster with Blueprint API.
You can choose to enable Kerberos when you lauch the plan.

> To finish, you need to set `hm_ambari::server::$server_service_ensure = 'running'`.

### Global settings

It permit to setup global setting use by agent and server.

```bash
class {'hm_ambari':
  ambari_version => '2.7.3.0',
  manage_repo => true,
  manage_java => true
}
```

You can use the following parameters:
- **ambari_version**: The ambari version you should to use (to use the right repo file). Default to `2.7.3.0`.
- **manage_repo**: If you should to use official public repository for Ambari. Default to `true`.
- **manage_java**: If you should to install Java OpenJDK. Default to `true`.
- **global_resources_ensure**: `present` or `absent`. Permit to clean repo file if you set `absent`. Default to `present`.
- **service_provider**: Permit to set the service provider. Default to `systemd`.

### Ambari agent

It permit to deploy Ambari agent.

```bash
class {'hm_ambari::agent':
  ambari_server => 'ambari-server.domain.com'
}
```

You can use the following parameters:
- **service_ensure**: Permit to stop or run ambari-agent services. You can use `stopped` or `running` value.
- **service_enable**: Permit to enable or disable ambari-agent services.
- **ambari_server_port**: Permit to set the port use by ambari server to communicate with ambari agent.
- **ambari_server_secure_port**: Permit to set the port use by ambari server to communicate with ambari agent in the secure way.
- **ambari_server**: It's the host or IP of ambari server.
- **ambari_agent_alias**: If you should to use alias name for your ambari agent instead of the FQDN. It's optionnal.
- **package_ensure**: To install or remove ambari-agent RPM.
- **ambari_agent_settings**: To set custom settings on ambari agent.

#### Ambari server

It permit to deploy Ambari server.

```bash
class {'hm_ambari::server':
    
}
```

You can use the following parameters:
- **service_ensure**: Permit to stop or run ambari-server services. You can use `stopped` or `running` value.
- **service_enable**: Permit to enable or disable ambari-server services.
- **package_ensure**: To install or remove ambari-server RPM.
- **ambari_server_settings**: To set custom settings on ambari server.
- **server_agent_ssl**: To enable two way SSL between agent and server.
- **disable_python_security**: The disable certificat SSL check on python. It's needed by some Ambari script.
- **ambari_cli_version**: Permit to choose the right version of Ambari cli: https://github.com/disaster37/go-ambari-rest/releases
- **install_ambari_cli**: Permit to install automatically the ambari cli.
- **hdp_privileges**: To create privilige file from hieradata YAML
- **hdp_repositories**: To create repository file from hieradata YAML
- **hdp_blueprint**: To create blueprint file from hieradata YAML
- **hdp_hosts_template**: To create host template file from hieradata YAML


## How to use tasks

### Ambari setup

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_setup                                                                                                 

hm_ambari::ambari_setup - Initializes Ambari server. You can also use it if you need to change database parameters

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_setup java_home=<value> db_type=<value> db_host=<value> db_port=<value> db_name=<value> db_user=<value> db_password=<value>

PARAMETERS:
- java_home: Optional[String[1]]
    Use specified java_home.  Must be valid on all hosts
- db_type: String[1]
    Database to use embedded|oracle|mysql|mssql|postgres|sqlanywhere
- db_host: String[1]
    Hostname of database server
- db_port: Optional[Integer[1]]
    Database port
- db_name: String[1]
    Database/Service name or ServiceID
- db_user: String[1]
    Database user login
- db_password: String[1]
    Database user password
```

Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_setup java_home=/usr/lib/jvm/java db_type=postgres db_host=db db_name=ambari db_user=ambari db_password=ambari
```

### Ambari init databases

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_init_database

hm_ambari::ambari_init_database - Initializes Ambari server database. Use only one time

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_init_database db_type=<value> db_host=<value> db_port=<value> db_name=<value> db_user=<value> db_password=<value>

PARAMETERS:
- db_type: String[1]
    Database to use embedded|oracle|mysql|mssql|postgres|sqlanywhere
- db_host: String[1]
    Hostname of database server
- db_port: Optional[Integer[1]]
    Database port
- db_name: String[1]
    Database/Service name or ServiceID
- db_user: String[1]
    Database user login
- db_password: String[1]
    Database user password
```

Sample:
```bash
bolt task run --nodes localhost package name=postgresql action=install
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_init_database db_type=postgres db_host=db db_name=ambari db_user=ambari db_password=ambari
```

### Ambari encrypt password

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_encrypt_password

hm_ambari::ambari_encrypt_password - Enable password encription on Ambari config files

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_encrypt_password master_key=<value> key_persist=<value>

PARAMETERS:
- master_key: String[1]
    Master key for encrypting passwords
- key_persist: Optional[Enum['true', 'false']]
    Persist master key [true/false]. Default to `true`
```

Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_encrypt_password master_key=ambari
```

### Ambari setup jdbc

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_setup_jdbc      

hm_ambari::ambari_setup_jdbc - Setup jdbc driver for Ambari

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_setup_jdbc jdbc_driver_path=<value> jdbc_db=<value>

PARAMETERS:
- jdbc_driver_path: String[1]
    Specifies the path to the JDBC driver JAR file or archive with all required files(jdbc jar, libraries and etc), for the database type specified with the --jdbc-db option
- jdbc_db: String[1]
    Specifies the database type [postgres|mysql|mssql|oracle|hsqldb|sqlanywhere] for the JDBC driver specified with the --jdbc-driver option
```

Sample:
```bash
bolt task run --nodes localhost package name=postgresql-jdbc action=install
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_setup_jdbc jdbc_driver_path=/usr/share/java/postgresql-jdbc.jar jdbc_db=postgres
```

### Ambari add mpack

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_add_mpack 

hm_ambari::ambari_add_mpack - Add mpack on Ambari

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_add_mpack mpack_file=<value> mpack_url=<value> proxy_url=<value> proxy_user=<value> proxy_password=<value>

PARAMETERS:
- mpack_file: Optional[String[1]]
    Specify the path for management pack to be installed/upgraded
- mpack_url: Optional[String[1]]
    Specify the url to download the mpack
- proxy_url: Optional[String[1]]
    The proxy chain if you need download the mpack. For exemple https://proxy.domain.com:8080
- proxy_user: Optional[String[1]]
    The proxy user if you need download the mpack
- proxy_password: Optional[String[1]]
    The proxy password if you need download the mpack
```

Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_add_mpack mpack_url=http://public-repo-1.hortonworks.com/HDP-SOLR/hdp-solr-ambari-mp/solr-service-mpack-3.0.0.tar.gz
```

### Ambari setup HTTPS

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_setup_https

hm_ambari::ambari_setup_https - Setup HTTPS for Ambari

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_setup_https api_ssl_port=<value> cert_path=<value> key_path=<value> cert_alias=<value>

PARAMETERS:
- api_ssl_port: Optional[Integer[1]]
    Client API SSL port. Default to `8443`
- cert_path: String[1]
    Path to Certificate (import)
- key_path: String[1]
    Path to Private Key (import)
- cert_alias: Optional[String[1]]
    Alias for the imported certificate. Default to `ambari`
```

Sample:
```bash
bolt command run --nodes localhost "openssl genrsa -out /tmp/ambari.key 2048"
bolt command run --nodes localhost "openssl req -new -x509 -days 365000 -key /tmp/ambari.key -out /tmp/ambari.crt -subj \"/C=US/ST=Denial/L=Springfield/O=Dis/CN=puppet.test.local\""
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost  hm_ambari::ambari_setup_https  api_ssl_port=8443 cert_path=/tmp/ambari.crt key_path=/tmp/ambari.key cert_alias=ambari
```

### Ambari setup truststore

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_setup_truststore

hm_ambari::ambari_setup_truststore - Setup truststore on Ambari server

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_setup_truststore truststore_type=<value> truststore_path=<value> truststore_password=<value> truststore_reconfigure=<value>

PARAMETERS:
- truststore_type: Optional[Enum[jks, jceks, pkcs12]]
    Type of TrustStore (jks|jceks|pkcs12). Default to `jks`
- truststore_path: String[1]
    Path of TrustStore
- truststore_password: String[1]
    Password for TrustStore
- truststore_reconfigure: Optional[Boolean]
    Force to reconfigure TrustStore if exits. Default to true
```

Sample:
```bash
bolt command run --nodes localhost "keytool -import -noprompt -file \"/tmp/ambari.crt\" -alias \"ambari\" -keystore \"/etc/ambari-server/truststore.jks\" -storepass \"ambari\""
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost  hm_ambari::ambari_setup_truststore  truststore_type=jks truststore_path=/etc/ambari-server/truststore.jks truststore_password=ambari truststore_reconfigure=true
```

### Ambari setup LDAP

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_setup_ldap      

hm_ambari::ambari_setup_ldap - Setup LDAP integration on Ambari server

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_setup_ldap ldap_type=<value> ldap_url=<value> ldap_secondary_url=<value> ldap_ssl=<value> ldap_user_class=<value> ldap_user_attr=<value> ldap_group_class=<value> ldap_group_attr=<value> ldap_member_attr=<value> ldap_dn=<value> ldap_base_dn=<value> ldap_referral=<value> ldap_bind_anonym=<value> ldap_manager_dn=<value> ldap_manager_password=<value> ldap_save_settings=<value> ldap_collision=<value> ldap_lowercase=<value> ldap_pagination=<value> admin_user=<value> admin_password=<value> truststore_type=<value> truststore_path=<value> truststore_password=<value>

PARAMETERS:
- ldap_type: Enum['AD', 'IPA', 'Generic']
    select the type of LDAP you want to use (AD, IPA, Generic LDAP). Default is `AD`
- ldap_url: String[1]
    Primary url for LDAP. For exemple `dc.domain.com:389`
- ldap_secondary_url: Optional[String[1]]
    Secondary url for LDAP. For exemple `dc2.domain.com:389`
- ldap_ssl: Optional[Enum['true', 'false']]
    Use SSL [true/false] for LDAP. Default to `false`
- ldap_user_class: Optional[String[1]]
    User Attribute Object Class for LDAP. Default to `person`
- ldap_user_attr: Optional[String[1]]
    User Attribute Name for LDAP. Default to `sAMAccountName`
- ldap_group_class: Optional[String[1]]
    Group Attribute Object Class for LDAP. Default to `group`
- ldap_group_attr: Optional[String[1]]
    Group Attribute Name for LDAP. Default to `cn`
- ldap_member_attr: Optional[String[1]]
    Group Membership Attribute Name for LDAP. Default to `member`
- ldap_dn: Optional[String[1]]
    Distinguished name attribute for LDAP. Default to `distunguishedName`
- ldap_base_dn: String[1]
    Base DN for LDAP. For exemple DC=DOMAIN,DC=COM
- ldap_referral: Optional[Enum[follow, ignore]]
    Referral method [follow/ignore] for LDAP. Default to `follow`
- ldap_bind_anonym: Optional[Enum['true', 'false']]
    Bind anonymously [true/false] for LDAPP. Default to `false`
- ldap_manager_dn: String[1]
    Manager DN for LDAP
- ldap_manager_password: String[1]
    Manager Password For LDAP
- ldap_save_settings: Optional[Boolean]
    Save without review for LDAP. Default to true
- ldap_collision: Optional[Enum[convert, skip]]
    Handling behavior for username collisions [convert/skip] for LDAP sync. Default to `convert`
- ldap_lowercase: Optional[Boolean]
    Declares whether to force the ldap user name to be lowercase or leave as-is
- ldap_pagination: Optional[Boolean]
    Determines whether results from LDAP are paginated when requested
- admin_user: Optional[String]
    Ambari administrator username for accessing Ambari's REST API. Default to `admin`
- admin_password: String[1]
    Ambari administrator password for accessing Ambari's REST API
- truststore_type: Optional[Enum[jks, jceks, pkcs12]]
    Type of TrustStore (jks|jceks|pkcs12). Default to `jks`
- truststore_path: Optional[String[1]]
    Path of TrustStore
- truststore_password: Optional[String[1]]
    Password for TrustStore
```

Help:
```bash
bolt task run --nodes localhost service name=ambari-server action=start
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_setup_ldap ldap_url=dc.domain.com:389 ldap_ssl=false ldap_user_class=person ldap_user_attr=sAMAccountName ldap_group_class=group ldap_group_attr=cn ldap_member_attr=member ldap_dn=distunguishedName ldap_base_dn=DOMAIN.COM ldap_referral=follow ldap_bind_anonym=false ldap_manager_dn=test ldap_manager_password=test ldap_save_settings=true ldap_collision=convert ldap_lowercase=true ldap_type=AD admin_user=admin admin_password=admin
```

### Ambari sync LDAP

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::ambari_sync_ldap 

hm_ambari::ambari_sync_ldap - Sync LDAP to provision user and group in Ambari

USAGE:
bolt task run --nodes <node-name> hm_ambari::ambari_sync_ldap group_path=<value> admin_user=<value> admin_password=<value>

PARAMETERS:
- group_path: String[1]
    LDAP sync groups option.  Specifies the path to a CSV file of group names to be synchronized.
- admin_user: String[1]
    Username for LDAP sync. Default to `admin`
- admin_password: String[1]
    Password for LDAP sync
```

Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_sync_ldap group_path=/dev/null admin_user=admin admin_password=admin
```

### HDP manage repository

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::hdp_manage_repository

hm_ambari::hdp_manage_repository - Manage HDP repository from Ambari API

USAGE:
bolt task run --nodes <node-name> hm_ambari::hdp_manage_repository ambari_url=<value> ambari_login=<value> ambari_password=<value> use_spacewalk=<value> repository_file=<value>

PARAMETERS:
- ambari_url: Optional[String[1]]
    The Ambari URL. Default to `http://localhost:8080/api/v1`
- ambari_login: Optional[String[1]]
    The Ambari login to connect on Ambari API. Default to `admin`
- ambari_password: String[1]
    The Ambari password to connect on Ambari API. Default to `admin`
- use_spacewalk: Optional[Boolean]
    Use it if your repository is managed by Spacewalk. Default to `false`
- repository_file: String[1]
    The Json file that describe the repository to add or update
```

Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_manage_repository ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin repository_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_repository.json
```

### HDP deploy cluster

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::hdp_deploy_cluster   

hm_ambari::hdp_deploy_cluster - Permit to deploy new cluster if not exist from API blueprint

USAGE:
bolt task run --nodes <node-name> hm_ambari::hdp_deploy_cluster ambari_url=<value> ambari_login=<value> ambari_password=<value> cluster_name=<value> blueprint_file=<value> host_template_file=<value>

PARAMETERS:
- ambari_url: Optional[String[1]]
    The Ambari URL. Default to `http://localhost:8080/api/v1`
- ambari_login: Optional[String[1]]
    The Ambari login to connect on Ambari API. Default to `admin`
- ambari_password: String[1]
    The Ambari password to connect on Ambari API. Default to `admin`
- cluster_name: String[1]
    The name of the cluster you should to create
- blueprint_file: String[1]
    The json file that describe the HDP topologie
- host_template_file: String[1]
    The Json file that describe the role of each HDP server
```

Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_deploy_cluster ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test blueprint_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_blueprint.json host_template_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_hoststemplate.json
```

### HDP manage permission

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::hdp_manage_permission

hm_ambari::hdp_manage_permission - Manage HDP permission from Ambari API

USAGE:
bolt task run --nodes <node-name> hm_ambari::hdp_manage_permission ambari_url=<value> ambari_login=<value> ambari_password=<value> privilege_file=<value>

PARAMETERS:
- ambari_url: Optional[String[1]]
    The Ambari URL. Default to `http://localhost:8080/api/v1`
- ambari_login: Optional[String[1]]
    The Ambari login to connect on Ambari API. Default to `admin`
- ambari_password: String[1]
    The Ambari password to connect on Ambari API. Default to `admin`
- privilege_file: String[1]
    The Json file that describe the privileges to add or update
```


Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_manage_permission ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin privilege_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_privilege.json
```

### HDP add node

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::hdp_add_node         

hm_ambari::hdp_add_node - Permit to add new node on existing cluster that be deploy from blueprint Ambari

USAGE:
bolt task run --nodes <node-name> hm_ambari::hdp_add_node ambari_url=<value> ambari_login=<value> ambari_password=<value> cluster_name=<value> blueprint_name=<value> hostname=<value> role=<value> rack=<value>

PARAMETERS:
- ambari_url: Optional[String[1]]
    The Ambari URL. Default to `http://localhost:8080/api/v1`
- ambari_login: Optional[String[1]]
    The Ambari login to connect on Ambari API. Default to `admin`
- ambari_password: String[1]
    The Ambari password to connect on Ambari API. Default to `admin`
- cluster_name: String[1]
    The HDP cluster name where you should to add the new node
- blueprint_name: String[1]
    The Blueprint name use to deploy the HDP cluster
- hostname: String[1]
    The name of the new node. Per default, it's the node's FQDN
- role: String[1]
    The Blueprint host_group to affect the new node
- rack: Optional[String[1]]
    The node rack for rack awerness
```

Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_add_node ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test blueprint_name=test hostname=puppet2.test.local  role=master
```

### HDP enable Kerberos

Help:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task show hm_ambari::hdp_enable_kerberos

hm_ambari::hdp_enable_kerberos - Permit to enable Kerberos on HDP from Ambari API

USAGE:
bolt task run --nodes <node-name> hm_ambari::hdp_enable_kerberos ambari_url=<value> ambari_login=<value> ambari_password=<value> cluster_name=<value> kdc_type=<value> disable_manage_identities=<value> kdc_hosts=<value> realm=<value> ldap_url=<value> container_dn=<value> domains=<value> admin_server_host=<value> principal_name=<value> principal_password=<value> persist_credential=<value> disable_install_packages=<value> executable_search_paths=<value> encryption_type=<value> password_length=<value> password_min_lowercase_letters=<value> password_min_uppercase_letters=<value> password_min_digits=<value> password_min_punctuation=<value> password_min_whitespace=<value> check_principal_name=<value> enable_case_insensitive_username_rules=<value> disable_manage_auth_to_local=<value> disable_create_ambari_principal=<value> master_kdc_host=<value> preconfigure_services=<value> ad_create_attributes_template=<value> disable_manage_krb5_conf=<value> krb5_conf_directory=<value> krb5_conf_template=<value>

PARAMETERS:
- ambari_url: Optional[String[1]]
    The Ambari URL. Default to `http://localhost:8080/api/v1`
- ambari_login: Optional[String[1]]
    The Ambari login to connect on Ambari API. Default to `admin`
- ambari_password: String[1]
    The Ambari password to connect on Ambari API. Default to `admin`
- cluster_name: String[1]
    The HDP cluster name where you should to enable kerberos
- kdc_type: Optional[String[1]]
    The kdc type to use (active-directory, mit-kdc or ipa) (default: 'active-directory')
- disable_manage_identities: Optional[Boolean]
    Manage Kerberos principals and keytabs manually
- kdc_hosts: String[1]
    A comma separated list of KDC host. Optionnaly a port number may be included
- realm: String[1]
    The default realm to use when creating service principal
- ldap_url: Optional[String[1]]
    The URL to Active Directory LDAP server. Only needed if the KDC type is Active Directory
- container_dn: Optional[String[1]]
    The DN of the container used store service principals. Only needed if you use Active Directory
- domains: Optional[String[1]]
    A comma separated list of domain names used to map server host names to the REALM name. It's optionnal
- admin_server_host: String[1]
    The host for KDC Kerberos administrative host. Optionnaly the port number can be included
- principal_name: String[1]
    Admin principal used to create principals and export keytabs
- principal_password: String[1]
    Admin principal password
- persist_credential: Optional[Boolean]
    Store admin credential. Need to enable password encryption before that
- disable_install_packages: Optional[Boolean]
    Disable the installation of Kerberos client package
- executable_search_paths: Optional[String[1]]
    A comma delimited list of search paths used to find Kerberos utilities (default: '/usr/bin, /usr/kerberos/bin, /usr/sbin, /usr/lib/mit/bin, /usr/lib/mit/sbin')
- encryption_type: Optional[String[1]]
    The supported list of session key encryption types that should be returned by the KDC (default: 'aes des3-cbc-sha1 rc4 des-cbc-md5')
- password_length: Optional[Integer]
    The password length (default: 20)
- password_min_lowercase_letters: Optional[Integer]
    The minimal lowercase letters to compose password (default: 1)
- password_min_uppercase_letters: Optional[Integer]
    The minimal uppercase letters to compose password (default: 1)
- password_min_digits: Optional[Integer]
    The minimal digits to compose password (default: 1)
- password_min_punctuation: Optional[Integer]
    The minimal punctuation to compose password (default: 1)
- password_min_whitespace: Optional[Integer]
    The minimal whitespace to compose password (default: 0)
- check_principal_name: Optional[String[1]]
    The principal name to use when executing Kerberos service check (default: '${cluster_name|toLower()}-${short_date}')
- enable_case_insensitive_username_rules: Optional[Boolean]
    Force principal names to resolv to lowercase local usernames in auth-to-local rules
- disable_manage_auth_to_local: Optional[Boolean]
    Don't manage the Hadoop auth-to-local rules by Ambari
- disable_create_ambari_principal: Optional[Boolean]
    Don't create principal and keytab by Ambari
- master_kdc_host: Optional[String[1]]
    The master KDC host in master/slave KDC deployment
- preconfigure_services: Optional[String[1]]
    Preconfigure service. Possible value are NONE, DEFAULT or ALL. (default: 'DEFAULT')
- ad_create_attributes_template: Optional[String[1]]
    A velocity template to use when create service principals in Active Directory.
- disable_manage_krb5_conf: Optional[Boolean]
    Don't manage krb5.conf by Ambari
- krb5_conf_directory: Optional[String[1]]
    The krb5.conf coonfiguration directory
- krb5_conf_template: Optional[String[1]]
    The krb5.conf template
```


Sample:
```bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_enable_kerberos ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test kdc_type=mit-kdc kdc_hosts=kdc.domain.com realm=DOMAIN.COM admin_server_host=kdc.domain.com principal_name=admin/admin@DOMAIN.COM principal_password=adminadmin domains=domain.com,.domain.com
```


## How to use deployement plan

### Setup Ambari

This deployement plan permit to initialize Ambari server:
- It create the main setting files
- It create database schema
- It enable password encryption on setting file
- It setup the JDBC driver path
- It setup HTTPS for Ambari UI/API
- It setup the truststore path
- It download and add mpack (if needed)
- It setup LDAP

Before to lauch it, you need to install the jdbc driver and client for your database.
For exemple, if you use PostgreSQL, you need to lauch

```bash
bolt task run package name=postgresql action=install --nodes <YOUR_AMBARI_SERVER_NODE>
bolt task run package name=postgresql-jdbc action=install --nodes <YOUR_AMBARI_SERVER_NODE>
```

Then you need to upload, or generate your certificat / key to enable HTTPS.
```bash
# To generate local self signed certificate
openssl genrsa -out /tmp/ambari.key 2048
openssl req -new -x509 -days 365000 -key /tmp/ambari.key -out /tmp/ambari.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=test"

bolt file upload /tmp/ambari.crt /tmp/ambari.crt --nodes <YOUR_AMBARI_SERVER_NODE>
bolt file upload /tmp/ambari.key /tmp/ambari.key --nodes <YOUR_AMBARI_SERVER_NODE>
```
Because you use HTTPS, you need to set your PKI certificate and chain in truststore. If you use self signed certificat, you need to add it on truststore instead
```bash
bolt command run "keytool -import -noprompt -file \"/tmp/ambari.crt\" -alias \"ambari\" -keystore \"/etc/ambari-server/truststore.jks\" -storepass \"ambari\"" --nodes <YOUR_AMBARI_SERVER_NODE>
```
Then set `truststore_path=/etc/ambari-server/truststore.jks`

If you shouldn't setup Ambari server with HTTPS, you need to add parameters `enable_https=false`.
Then you doesn't need to set the following parameters `cert_key_path`, `cert_crt_path`, `api_ssl_port` and `cert_alias`

If you shouldn't setup LDAP, you need to add parameters `enable_ldap=false`.
Then you doesn't need to set paremeters about LDAP settings.

To finish, you can setup Ambari
```bash
bolt --modulepath /etc/puppetlabs/code/modules plan run hm_ambari::ambari_setup --nodes <YOUR_AMBARI_SERVER_NODE> \
  db_type=postgres\
  db_host=db\
  db_name=ambari\
  db_user=ambari\
  db_password=ambari\
  db_port=5432\
  master_key=mysecretkey\
  jdbc_driver_path=/usr/share/java/postgresql-jdbc.jar\
  cert_key_path=/tmp/ambari.key\
  cert_crt_path=/tmp/ambari.crt\
  truststore_path=/etc/ambari-server/truststore.jks\
  ldap_url=dc.domain.com:636\
  ldap_base_dn=DOMAIN.COM\
  ldap_manager_dn=ldap_user\
  ldap_manager_password=ldap_password\
  admin_password=admin
```


The full list of availables paremeters:
```bash
bolt --modulepath /etc/puppetlabs/code/modules plan show hm_ambari::ambari_setup

hm_ambari::ambari_setup

USAGE:
bolt plan run hm_ambari::ambari_setup nodes=<value> [java_home=<value>] db_type=<value> db_host=<value> db_port=<value> db_name=<value> db_user=<value> db_password=<value> master_key=<value> jdbc_driver_path=<value> [enable_https=<value>] [cert_key_path=<value>] [cert_crt_path=<value>] [api_ssl_port=<value>] [cert_alias=<value>] [truststore_path=<value>] [mpacks_url=<value>] [proxy_url=<value>] [proxy_user=<value>] [proxy_password=<value>] [enable_ldap=<value>] [ldap_url=<value>] [ldap_secondary_url=<value>] [ldap_ssl=<value>] [ldap_type=<value>] [ldap_user_class=<value>] [ldap_user_attr=<value>] [ldap_group_class=<value>] [ldap_group_attr=<value>] [ldap_member_attr=<value>] [ldap_dn=<value>] [ldap_base_dn=<value>] [ldap_referral=<value>] [ldap_bind_anonym=<value>] [ldap_manager_dn=<value>] [ldap_manager_password=<value>] [ldap_save_settings=<value>] [ldap_collision=<value>] [ldap_lowercase=<value>] [admin_user=<value>] [admin_password=<value>]

PARAMETERS:
- nodes: TargetSpec
- java_home: String
- db_type: String
- db_host: String
- db_port: Integer
- db_name: String
- db_user: String
- db_password: String
- master_key: String
- jdbc_driver_path: String
- enable_https: Boolean
- cert_key_path: Optional[String]
- cert_crt_path: Optional[String]
- api_ssl_port: Optional[Integer]
- cert_alias: Optional[String]
- truststore_path: Optional[String]
- mpacks_url: Array[String]
- proxy_url: Optional[String]
- proxy_user: Optional[String]
- proxy_password: Optional[String]
- enable_ldap: Boolean
- ldap_url: Optional[String]
- ldap_secondary_url: Optional[String]
- ldap_ssl: Optional[Enum['false', 'true']]
- ldap_type: Optional[String]
- ldap_user_class: Optional[String]
- ldap_user_attr: Optional[String]
- ldap_group_class: Optional[String]
- ldap_group_attr: Optional[String]
- ldap_member_attr: Optional[String]
- ldap_dn: Optional[String]
- ldap_base_dn: Optional[String]
- ldap_referral: Optional[String]
- ldap_bind_anonym: Optional[Enum['false', 'true']]
- ldap_manager_dn: Optional[String]
- ldap_manager_password: Optional[String]
- ldap_save_settings: Optional[Boolean]
- ldap_collision: Optional[String]
- ldap_lowercase: Optional[Boolean]
- admin_user: Optional[String]
- admin_password: Optional[String]
```

### Deploy HDP


This deployement plan permit to deploy HDP cluster:
- It configure the HDP repositories
- It deploy HDP topologie from blueprint file and host template file
- It manage privileges on Ambari
- It setup Kerberos on HDP

Before to lauch it, you need to install the kerberos cli on Ambari server if you need to enable it.

```bash
bolt task run package name=krb5-workstation action=install --nodes <YOUR_AMBARI_SERVER_NODE>
bolt task run package name=krb5-libs action=install --nodes <YOUR_AMBARI_SERVER_NODE>
```

Then you need to configure the `/etc/krb5.conf` file.

After that you need to put the following file on your ambari server:
- repositories.json file: You can use bolt to upload it or use $hm_ambari::server::hdp_repositories to generate it
- blueprint.json file: You can use bolt to upload it or use $hm_ambari::server::hdp_blueprint to generate it
- hosts-template.json file: You can use bolt to upload it or use $hm_ambari::server::hdp_hosts_template to generate it
- (optionnal) privileges.json file: You can use bolt to upload it or use $hm_ambari::server::hdp_privileges to generate it


To finish, you can deploy HDP
```bash
bolt --modulepath /etc/puppetlabs/code/modules plan run hm_ambari::deploy_hdp --nodes <YOUR_AMBARI_SERVER_NODE> \
  cluster_name=mycluster\
  repository_file=/etc/ambari-server/conf/api/repositories.json\
  blueprint_file=/etc/ambari-server/conf/api/blueprint.json\
  host_template_file=/etc/ambari-server/conf/api/hoststemplate.json\
  privilege_file=/etc/ambari-server/conf/api/privileges.json\
  enable_kerberos=true\
  kdc_type=active-directory\
  kdc_hosts=dc.domain.com\
  realm=DOMAIN.COM\
  ldap_url=ldaps://dc.domain.com:636\
  container_dn=OU=HDP,DC=DOMAIN,DC=COM\
  domains=domain.com,.domain.com\
  admin_server_host=dc.domain.com\
  principal_name=user@DOMAIN.COM\
  principal_password=password\
  persist_credential=true
```


The full list of availables paremeters:
```bash
bolt --modulepath /etc/puppetlabs/code/modules plan show hm_ambari::deploy_hdp

hm_ambari::deploy_hdp

USAGE:
bolt plan run hm_ambari::deploy_hdp nodes=<value> [ambari_url=<value>] [ambari_login=<value>] [ambari_password=<value>] [use_spacewalk=<value>] cluster_name=<value> repository_file=<value> blueprint_file=<value> host_template_file=<value> [privilege_file=<value>] [enable_kerberos=<value>] [kdc_type=<value>] [disable_manage_identities=<value>] [kdc_hosts=<value>] [realm=<value>] [ldap_url=<value>] [container_dn=<value>] [domains=<value>] [admin_server_host=<value>] [principal_name=<value>] [principal_password=<value>] [persist_credential=<value>] [disable_install_packages=<value>] [executable_search_paths=<value>] [encryption_type=<value>] [password_length=<value>] [password_min_lowercase_letters=<value>] [password_min_uppercase_letters=<value>] [password_min_digits=<value>] [password_min_punctuation=<value>] [password_min_whitespace=<value>] [check_principal_name=<value>] [enable_case_insensitive_username_rules=<value>] [disable_manage_auth_to_local=<value>] [disable_create_ambari_principal=<value>] [master_kdc_host=<value>] [preconfigure_services=<value>] [ad_create_attributes_template=<value>] [disable_manage_krb5_conf=<value>] [krb5_conf_directory=<value>] [krb5_conf_template=<value>]

PARAMETERS:
- nodes: TargetSpec
- ambari_url: String
- ambari_login: String
- ambari_password: String
- use_spacewalk: Boolean
- cluster_name: String
- repository_file: String
- blueprint_file: String
- host_template_file: String
- privilege_file: Optional[String]
- enable_kerberos: Boolean
- kdc_type: Optional[String]
- disable_manage_identities: Optional[Boolean]
- kdc_hosts: Optional[String]
- realm: Optional[String]
- ldap_url: Optional[String]
- container_dn: Optional[String]
- domains: Optional[String]
- admin_server_host: Optional[String]
- principal_name: Optional[String]
- principal_password: Optional[String]
- persist_credential: Optional[Boolean]
- disable_install_packages: Optional[Boolean]
- executable_search_paths: Optional[String]
- encryption_type: Optional[String]
- password_length: Optional[Integer]
- password_min_lowercase_letters: Optional[Integer]
- password_min_uppercase_letters: Optional[Integer]
- password_min_digits: Optional[Integer]
- password_min_punctuation: Optional[Integer]
- password_min_whitespace: Optional[Integer]
- check_principal_name: Optional[String]
- enable_case_insensitive_username_rules: Optional[Boolean]
- disable_manage_auth_to_local: Optional[Boolean]
- disable_create_ambari_principal: Optional[Boolean]
- master_kdc_host: Optional[String]
- preconfigure_services: Optional[String]
- ad_create_attributes_template: Optional[String]
- disable_manage_krb5_conf: Optional[Boolean]
- krb5_conf_directory: Optional[String]
- krb5_conf_template: Optional[String]


## How to contribute

The PR are always welcome. Please use the developpment branch to do PR.

### How to lauch acceptances tests


If you change the manifests, tasks or plans, don't forget to update the acceptance tests and run it before doing PR

```bash
docker-compose run --rm puppet bash
pdk validate --puppet-version 5.3.7
rake beaker
```


### How to lauch manual test

#### Test module

##### Agent
```bash
docker-compose down -v
docker-compose up -d
docker-compose exec puppet bash
r10k puppetfile install --puppetfile Puppetfile --moduledir /etc/puppetlabs/code/modules/
puppet apply tests/site-agent-default.pp
```

##### Server
```bash
docker-compose down -v
docker-compose up -d
docker exec puppet bash
r10k puppetfile install --puppetfile Puppetfile --moduledir /etc/puppetlabs/code/modules/
puppet apply tests/site-server-default.pp
```

#### Tests tasks

To cleanup your environment, lauch the following command:

```bash
docker-compose down -v
docker-compose up -d
docker-compose exec puppet bash
r10k puppetfile install --puppetfile Puppetfile --moduledir /etc/puppetlabs/code/modules/
puppet apply tests/site-server-default.pp
puppet apply tests/site-agent-default.pp
```

> if you need proxy do download yum package you need to set the proxy on /etc/yum.conf because of ambari not use environment variable http_proxy or https_proxy when it install yum package.
> `echo "proxy=${http_proxy}" >> /etc/yum.conf`

##### hm_ambari::ambari_setup

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_setup java_home=/usr/lib/jvm/java db_type=postgres db_host=db db_name=ambari db_user=ambari db_password=ambari
```

##### hm_ambari::ambari_init_database

```bash
docker-compose exec puppet bash
bolt task run --nodes localhost package name=postgresql action=install
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_init_database db_type=postgres db_host=db db_name=ambari db_user=ambari db_password=ambari
```

##### hm_ambari::ambari_encrypt_password

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_encrypt_password master_key=ambari
```

##### hm_ambari::ambari_setup_jdbc

```bash
docker-compose exec puppet bash
bolt task run --nodes localhost package name=postgresql-jdbc action=install
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_setup_jdbc jdbc_driver_path=/usr/share/java/postgresql-jdbc.jar jdbc_db=postgres
```

##### hm_ambari::ambari_add_mpack

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_add_mpack mpack_url=http://public-repo-1.hortonworks.com/HDP-SOLR/hdp-solr-ambari-mp/solr-service-mpack-3.0.0.tar.gz
```

##### hm_ambari::ambari_setup_https

```bash
docker-compose exec puppet bash
bolt command run --nodes localhost "openssl genrsa -out /tmp/ambari.key 2048"
bolt command run --nodes localhost "openssl req -new -x509 -days 365000 -key /tmp/ambari.key -out /tmp/ambari.crt -subj \"/C=US/ST=Denial/L=Springfield/O=Dis/CN=puppet.test.local\""
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost  hm_ambari::ambari_setup_https  api_ssl_port=8443 cert_path=/tmp/ambari.crt key_path=/tmp/ambari.key cert_alias=ambari
```

##### hm_ambari::ambari_setup_truststore

```bash
docker-compose exec puppet bash
bolt command run --nodes localhost "keytool -import -noprompt -file \"/tmp/ambari.crt\" -alias \"ambari\" -keystore \"/etc/ambari-server/truststore.jks\" -storepass \"ambari\""
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost  hm_ambari::ambari_setup_truststore  truststore_type=jks truststore_path=/etc/ambari-server/truststore.jks truststore_password=ambari truststore_reconfigure=true
```

##### hm_ambari::ambari_setup_ldap

```bash
docker-compose exec puppet bash
bolt task run --nodes localhost service name=ambari-server action=start
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_setup_ldap ldap_url=dc.domain.com:389 ldap_ssl=false ldap_user_class=person ldap_user_attr=sAMAccountName ldap_group_class=group ldap_group_attr=cn ldap_member_attr=member ldap_dn=distunguishedName ldap_base_dn=DOMAIN.COM ldap_referral=follow ldap_bind_anonym=false ldap_manager_dn=test ldap_manager_password=test ldap_save_settings=true ldap_collision=convert ldap_lowercase=true ldap_type=AD admin_user=admin admin_password=admin
```

##### hm_ambari::ambari_sync_ldap

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::ambari_sync_ldap group_path=/dev/null admin_user=admin admin_password=admin
```

##### hm_ambari::hdp_manage_repository

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_manage_repository ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin repository_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_repository.json
```

##### hm_ambari::hdp_deploy_cluster

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_deploy_cluster ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test blueprint_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_blueprint.json host_template_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_hoststemplate.json
```

##### hm_ambari::hdp_manage_permission

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_manage_permission ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin privilege_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_privilege.json
```

##### hm_ambari::hdp_add_node

```bash
docker-compose exec puppet bash
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_add_node ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test blueprint_name=test hostname=puppet2.test.local  role=master
```

##### hm_ambari::hdp_enable_kerberos


```bash
docker-compose exec puppet bash
bolt task run --nodes localhost package name=krb5-workstation action=install
bolt task run --nodes localhost package name=krb5-libs action=install
bolt --modulepath /etc/puppetlabs/code/modules task run --nodes localhost hm_ambari::hdp_enable_kerberos ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test kdc_type=mit-kdc kdc_hosts=kdc.test.local realm=TEST.LOCAL admin_server_host=kdc.test.local principal_name=admin/admin@TEST.LOCAL principal_password=adminadmin domains=test.local,.test.local disable_manage_krb5_conf=true
```

#### Tests plans

To cleanup your environment, lauch the following command:

```bash
docker-compose down -v
docker-compose up -d
docker-compose exec puppet bash
r10k puppetfile install --puppetfile Puppetfile --moduledir /etc/puppetlabs/code/modules/
puppet apply tests/site-server-default.pp
puppet apply tests/site-agent-default.pp
```

> if you need proxy do download yum package you need to set the proxy on /etc/yum.conf because of ambari not use environment variable http_proxy or https_proxy when it install yum package.
> `echo "proxy=${http_proxy}" >> /etc/yum.conf`

##### hm_ambari::ambari_setup

```bash
docker-compose exec puppet bash
bolt task run --nodes localhost package name=postgresql-jdbc action=install
bolt command run --nodes localhost "openssl genrsa -out /tmp/ambari.key 2048"
bolt command run --nodes localhost "openssl req -new -x509 -days 365000 -key /tmp/ambari.key -out /tmp/ambari.crt -subj \"/C=US/ST=Denial/L=Springfield/O=Dis/CN=puppet.test.local\""
bolt command run --nodes localhost "keytool -import -noprompt -file \"/tmp/ambari.crt\" -alias \"ambari\" -keystore \"/etc/ambari-server/truststore.jks\" -storepass \"ambari\""
bolt --modulepath /etc/puppetlabs/code/modules plan run hm_ambari::ambari_setup --nodes localhost \
  db_type=postgres\
  db_host=db\
  db_name=ambari\
  db_user=ambari\
  db_password=ambari\
  db_port=5432\
  master_key=mysecretkey\
  jdbc_driver_path=/usr/share/java/postgresql-jdbc.jar\
  cert_key_path=/tmp/ambari.key\
  cert_crt_path=/tmp/ambari.crt\
  truststore_path=/etc/ambari-server/truststore.jks\
  ldap_url=dc.domain.com:636\
  ldap_base_dn=DOMAIN.COM\
  ldap_manager_dn=ldap_user\
  ldap_manager_password=ldap_password\
  admin_password=admin
```

##### hm_ambari::deploy_hdp

```bash
docker-compose exec puppet bash
bolt task run --nodes localhost package name=krb5-workstation action=install
bolt task run --nodes localhost package name=krb5-libs action=install
bolt --modulepath /etc/puppetlabs/code/modules plan run hm_ambari::deploy_hdp --nodes localhost \
  cluster_name=test\
  repository_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_repository.json\
  blueprint_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_blueprint.json\
  host_template_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_hoststemplate.json\
  privilege_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_privilege.json\
  enable_kerberos=true\
  kdc_type=mit-kdc\
  kdc_hosts=kdc.test.local\
  realm=TEST.LOCAL\
  domains=test.local,.test.local\
  admin_server_host=kdc.test.local\
  principal_name=admin/admin@TEST.LOCAL\
  principal_password=adminadmin\
  disable_manage_krb5_conf=true
```