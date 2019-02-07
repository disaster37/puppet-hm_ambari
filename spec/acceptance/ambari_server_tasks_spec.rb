require 'spec_helper_acceptance'
require 'uri'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'ambari server tasks' do
  describe 'Deploy ambari server' do
    it 'setup database' do
      shell('postgresql-setup initdb')
      shell('echo "host    all             postgres             127.0.0.1/32            trust" > /var/lib/pgsql/data/pg_hba.conf')
      shell('echo "local    all             postgres                        trust" >> /var/lib/pgsql/data/pg_hba.conf')
      shell('echo "host    all             all             127.0.0.1/32            md5" >> /var/lib/pgsql/data/pg_hba.conf')
      shell('echo "track_counts = on" >> /var/lib/pgsql/data/postgresql.conf')
      shell('echo "autovacuum = on" >> /var/lib/pgsql/data/postgresql.conf')
      shell('echo "listen_addresses = \'*\'" >> /var/lib/pgsql/data/postgresql.conf')
      shell('systemctl start postgresql.service')
      query = "sudo -u postgres psql -U postgres postgres -c \"CREATE ROLE ambari LOGIN UNENCRYPTED PASSWORD 'ambari' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;\""
      shell(query)
      shell('sudo -u postgres createdb -E utf8 -O ambari ambari')

      query = "sudo -u postgres psql -U postgres postgres -c  \"CREATE ROLE hive LOGIN UNENCRYPTED PASSWORD 'hive' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;\""
      shell(query)
      shell('sudo -u postgres createdb -E utf8 -O hive hive')

      query = "sudo -u postgres psql -U postgres postgres -c \"CREATE ROLE ranger LOGIN UNENCRYPTED PASSWORD 'ranger' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;\""
      shell(query)
      shell('sudo -u postgres createdb -E utf8 -O ranger ranger')

      query = "sudo -u postgres psql -U postgres postgres -c \"CREATE ROLE oozie LOGIN UNENCRYPTED PASSWORD 'oozie' NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;\""
      shell(query)
      shell('sudo -u postgres createdb -E utf8 -O oozie oozie')
    end
    
    it 'start kerberos' do
      shell('kdb5_util create -s -P adminadmin')
      shell('service krb5kdc start')
      shell('service kadmin start')
      shell('kadmin.local -q "addprinc -pw adminadmin admin/admin"')
      shell('sed -i.bak "s/EXAMPLE.COM/TEST.LOCAL/g" /var/kerberos/krb5kdc/kadm5.acl')
      shell('service kadmin restart')
    end
    
    it 'set yum proxy' do
      shell('echo "proxy=${http_proxy}" >> /etc/yum.conf')
    end

    it 'runs successfully' do
      pp = <<-EOS
        class { 'hm_ambari::server':}
        class { 'hm_ambari::agent':}
        package { ['postgresql', 'postgresql-jdbc'] :
          ensure => 'present'
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end

    it 'execute Ambari setup' do
      result = run_task(
        task_name: 'hm_ambari::ambari_setup',
        params: 'java_home=/usr/lib/jvm/java db_type=postgres db_host=127.0.0.1 db_name=ambari db_user=ambari db_password=ambari',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Ambari Server 'setup' completed successfully}])
    end

    it 'execute Ambari init database' do
      result = run_task(
        task_name: 'hm_ambari::ambari_init_database',
        params: 'db_type=postgres db_host=127.0.0.1 db_name=ambari db_user=ambari db_password=ambari',
      )
      expect_multiple_regexes(result: result, regexes: [%r{CREATE INDEX}])
    end

    it 'execute Ambari encrypt password' do
      result = run_task(
        task_name: 'hm_ambari::ambari_encrypt_password',
        params: 'master_key=ambari',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Ambari Server 'setup-security' completed successfully}])
    end

    it 'execute Ambari setup jdbc' do
      result = run_task(
        task_name: 'hm_ambari::ambari_setup_jdbc',
        params: 'jdbc_driver_path=/usr/share/java/postgresql-jdbc.jar jdbc_db=postgres',
      )
      expect_multiple_regexes(result: result, regexes: [%r{JDBC driver was successfully initialized}])
    end

    it 'execute Ambari add mpack' do
      if ENV['http_proxy'].nil?
        result = run_task(
          task_name: 'hm_ambari::ambari_add_mpack',
          params: 'mpack_url=http://public-repo-1.hortonworks.com/HDP-SOLR/hdp-solr-ambari-mp/solr-service-mpack-3.0.0.tar.gz',
        )
      else
        uri = URI.parse(ENV['http_proxy'])
        proxy = uri.scheme + '://' + uri.host + ':' + uri.port.to_s
        result = run_task(
          task_name: 'hm_ambari::ambari_add_mpack',
          params: 'mpack_url=http://public-repo-1.hortonworks.com/HDP-SOLR/hdp-solr-ambari-mp/solr-service-mpack-3.0.0.tar.gz proxy_url=' + proxy + ' proxy_user=' + uri.user + ' proxy_password=' + uri.password,
        )
      end

      expect_multiple_regexes(result: result, regexes: [%r{Ambari Server 'install-mpack' completed successfully}])
    end

    it 'execute Ambari setup https' do
      shell('openssl genrsa -out /tmp/ambari.key 2048')
      shell('openssl req -new -x509 -days 365000 -key /tmp/ambari.key -out /tmp/ambari.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=test"')
      result = run_task(
        task_name: 'hm_ambari::ambari_setup_https',
        params: 'api_ssl_port=8443 cert_path=/tmp/ambari.crt key_path=/tmp/ambari.key cert_alias=ambari',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Adjusting ambari-server permissions and ownership}])
    end

    it 'execute Ambari setup truststore' do
      shell('keytool -import -noprompt -file "/tmp/ambari.crt" -alias "ambari" -keystore "/etc/ambari-server/truststore.jks" -storepass "ambari"')
      result = run_task(
        task_name: 'hm_ambari::ambari_setup_truststore',
        params: 'truststore_type=jks truststore_path=/etc/ambari-server/truststore.jks truststore_password=ambari truststore_reconfigure=true',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Ambari Server 'setup-security' completed successfully}])
    end

    it 'execute Ambari setup ldap' do
      shell('ambari-server start')
      result = run_task(
        task_name: 'hm_ambari::ambari_setup_ldap',
        params: 'ldap_type=AD ldap_url=dc.domain.com:389 ldap_ssl=false ldap_user_class=person ldap_user_attr=sAMAccountName ldap_group_class=group ldap_group_attr=cn ldap_member_attr=member ldap_dn=distunguishedName ldap_base_dn=HM.DM.AD ldap_referral=follow ldap_bind_anonym=false ldap_manager_dn=test ldap_manager_password=test ldap_save_settings=true ldap_collision=convert ldap_lowercase=true admin_user=admin admin_password=admin',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Ambari Server 'setup-ldap' completed successfully}])
    end

    it 'execute Ambari sync ldap' do
      result = run_task(
        task_name: 'hm_ambari::ambari_sync_ldap',
        params: 'group_path=/dev/null admin_user=admin admin_password=admin',
      )
      # Because we have no valide LDAP server, the task failed, but the syntax is right.
      expect_multiple_regexes(result: result, regexes: [%r{Connection timed out}])
    end

    it 'execute HDP manage repository' do
      result = run_task(
        task_name: 'hm_ambari::hdp_manage_repository',
        params: 'ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin repository_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_repository.json',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Repository created successfully}])
    end

    it 'execute HDP deploy cluster' do
      result = run_task(
        task_name: 'hm_ambari::hdp_deploy_cluster',
        params: 'ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test blueprint_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_blueprint.json host_template_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_hoststemplate_spec.json',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Cluster created successfully}])
    end

    it 'execute HDP manage permission' do
      result = run_task(
        task_name: 'hm_ambari::hdp_manage_permission',
        params: 'ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin privilege_file=/etc/puppetlabs/code/modules/hm_ambari/tests/hdp_privilege.json',
      )
      expect_multiple_regexes(result: result, regexes: [%r{Create privilege admin / CLUSTER.ADMINISTRATOR successfully}])
    end

    it 'execute HDP add node' do
      result = run_task(
        task_name: 'hm_ambari::hdp_add_node',
        params: 'ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test blueprint_name=test hostname=puppet2.test.local  role=master',
      )
      # We just test if syntax is right
      expect_multiple_regexes(result: result, regexes: [%r{Host puppet2.test.local not found}])
    end
    
    it 'execute HDP enable kerberos' do
      result = run_task(
        task_name: 'hm_ambari::hdp_enable_kerberos',
        params: 'ambari_url=https://127.0.0.1:8443/api/v1 ambari_login=admin ambari_password=admin cluster_name=test kdc_type=mit-kdc kdc_hosts=centos-7-x64 realm=TEST.LOCAL admin_server_host=centos-7-x64 principal_name=admin/admin@TEST.LOCAL principal_password=adminadmin domains=test.local,.test.local disable_manage_krb5_conf=true',
      )
      # We just test if syntax is right
      expect_multiple_regexes(result: result, regexes: [%r{Kerberos is enabled}])
    end
  end
end
