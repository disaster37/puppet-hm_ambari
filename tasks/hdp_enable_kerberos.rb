#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def enable_kerberos(ambari_url, ambari_login, ambari_password, cluster_name, kdc_type, disable_manage_identities, kdc_hosts, realm, ldap_url, container_dn, domains, admin_server_host, principal_name, principal_password, persist_credential, disable_install_packages, executable_search_paths, encryption_type, password_length, password_min_lowercase_letters, password_min_uppercase_letters, password_min_digits, password_min_punctuation, password_min_whitespace, check_principal_name, enable_case_insensitive_username_rules, disable_manage_auth_to_local, disable_create_ambari_principal, master_kdc_host, preconfigure_services, ad_create_attributes_template, disable_manage_krb5_conf, krb5_conf_directory, krb5_conf_template)
  cmd_string = 'ambari-cli_linux_amd64'
  cmd_string << " --ambari-url \"#{ambari_url}\"" unless ambari_url.nil?
  cmd_string << " --ambari-login \"#{ambari_login}\"" unless ambari_login.nil?
  cmd_string << " --ambari-password \"#{ambari_password}\"" unless ambari_password.nil?
  cmd_string << ' configure-kerberos'
  cmd_string << " --cluster-name \"#{cluster_name}\"" unless cluster_name.nil?
  cmd_string << " --kdc-type \"#{kdc_type}\"" unless kdc_type.nil?
  cmd_string << " --kdc-hosts \"#{kdc_hosts}\"" unless kdc_hosts.nil?
  cmd_string << " --realm \"#{realm}\"" unless realm.nil?
  cmd_string << " --ldap-url \"#{ldap_url}\"" unless ldap_url.nil?
  cmd_string << " --container-dn \"#{container_dn}\"" unless container_dn.nil?
  cmd_string << " --domains \"#{domains}\"" unless domains.nil?
  cmd_string << " --admin-server-host \"#{admin_server_host}\"" unless admin_server_host.nil?
  cmd_string << " --principal-name \"#{principal_name}\"" unless principal_name.nil?
  cmd_string << " --principal-password \"#{principal_password}\"" unless principal_password.nil?
  cmd_string << " --executable-search-paths \"#{executable_search_paths}\"" unless executable_search_paths.nil?
  cmd_string << " --encryption-type \"#{encryption_type}\"" unless encryption_type.nil?
  cmd_string << " --password-length #{password_length}" unless password_length.nil?
  cmd_string << " --password-min-lowercase-letters #{password_min_lowercase_letters}" unless password_min_lowercase_letters.nil?
  cmd_string << " --password-min-uppercase-letters #{password-min-uppercase-letters}" unless password_min_uppercase_letters.nil?
  cmd_string << " --password-min-digits #{password_min_digits}" unless password_min_digits.nil?
  cmd_string << " --password-min-punctuation #{password_min_punctuation}" unless password_min_punctuation.nil?
  cmd_string << " --password-min-whitespace #{password_min_whitespace}" unless password_min_whitespace.nil?
  cmd_string << " --check-principal-name \"#{check_principal_name}\"" unless check_principal_name.nil?
  cmd_string << " --master-kdc-host \"#{master_kdc_host}\"" unless master_kdc_host.nil?
  cmd_string << " --preconfigure-services \"#{preconfigure_services}\"" unless preconfigure_services.nil?
  cmd_string << " --ad_create_attributes_template \"#{ad_create_attributes_template}\"" unless ad_create_attributes_template.nil?
  cmd_string << " --krb5-conf-directory \"#{krb5_conf_directory}\"" unless krb5_conf_directory.nil?
  cmd_string << " --krb5-conf-template \"#{krb5_conf_template}\"" unless krb5_conf_template.nil?
  cmd_string << " --disable-manage-identities" if disable_manage_identities
  cmd_string << " --persist-credential" if persist_credential
  cmd_string << " --disable-install-packages" if disable_install_packages
  cmd_string << " --enable-case-insensitive-username-rules" if enable_case_insensitive_username_rules
  cmd_string << " --disable-manage-auth-to-local" if disable_manage_auth_to_local
  cmd_string << " --disable-create-ambari-principal" if disable_create_ambari_principal
  cmd_string << " --disable-manage-krb5-conf" if disable_manage_krb5_conf

  #puts cmd_string

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
ambari_url = params.fetch('ambari_url', 'http://localhost:8080/api/v1')
ambari_login = params.fetch('ambari_login', 'admin')
ambari_password = params.fetch('ambari_password', 'admin')
cluster_name = params['cluster_name']
kdc_type = params['kdc_type']
disable_manage_identities = params['disable_manage_identities']
kdc_hosts = params['kdc_hosts']
realm = params['realm']
ldap_url = params['ldap_url']
container_dn = params['container_dn']
domains = params['domains']
admin_server_host = params['admin_server_host']
principal_name = params['principal_name']
principal_password = params['principal_password']
persist_credential = params['persist_credential']
disable_install_packages = params['disable_install_packages']
executable_search_paths = params['executable_search_paths']
encryption_type = params['encryption_type']
password_length = params['password_length']
password_min_lowercase_letters = params['password_min_lowercase_letters']
password_min_uppercase_letters = params['password_min_uppercase_letters']
password_min_digits = params['password_min_digits']
password_min_punctuation = params['password_min_punctuation']
password_min_whitespace = params['password_min_whitespace']
check_principal_name = params['check_principal_name']
enable_case_insensitive_username_rules = params['enable_case_insensitive_username_rules']
disable_manage_auth_to_local = params['disable_manage_auth_to_local']
disable_create_ambari_principal = params['disable_create_ambari_principal']
master_kdc_host = params['master_kdc_host']
preconfigure_services = params['preconfigure_services']
ad_create_attributes_template = params['ad_create_attributes_template']
disable_manage_krb5_conf = params['disable_manage_krb5_conf']
krb5_conf_directory = params['krb5_conf_directory']
krb5_conf_template = params['krb5_conf_template']

begin
  result = enable_kerberos(ambari_url, ambari_login, ambari_password, cluster_name, kdc_type, disable_manage_identities, kdc_hosts, realm, ldap_url, container_dn, domains, admin_server_host, principal_name, principal_password, persist_credential, disable_install_packages, executable_search_paths, encryption_type, password_length, password_min_lowercase_letters, password_min_uppercase_letters, password_min_digits, password_min_punctuation, password_min_whitespace, check_principal_name, enable_case_insensitive_username_rules, disable_manage_auth_to_local, disable_create_ambari_principal, master_kdc_host, preconfigure_services, ad_create_attributes_template, disable_manage_krb5_conf, krb5_conf_directory, krb5_conf_template)
  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
