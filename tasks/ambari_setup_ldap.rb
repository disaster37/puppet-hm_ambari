#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def ambari_setup_ldap(
    ldap_type, ldap_url,
    ldap_secondary_url,
    ldap_ssl,
    ldap_user_class,
    ldap_user_attr,
    ldap_group_class,
    ldap_group_attr,
    ldap_member_attr,
    ldap_dn,
    ldap_base_dn,
    ldap_referral,
    ldap_bind_anonym,
    ldap_manager_dn,
    ldap_manager_password,
    ldap_save_settings,
    ldap_collision,
    ldap_lowercase,
    ldap_pagination,
    ambari_login,
    ambari_password,
    truststore_type,
    truststore_path,
    truststore_password
)

  # Check the ambari version for retro compatibility
  result_ambari_version = `ambari-server --version`
  if(result_ambari_version =~ /^2.6.*$/)
    puts("Ambari 2.6 detected")
    is_old_version = true
  else
    is_old_version = false
  end
  

  # It force prompt the secondary if we set nothink
  if ldap_secondary_url.nil?
    ldap_secondary_url = ldap_url
  end

  # There are not currently option to set ldap type, so it prompt as interactive
  cmd_string = 'ambari-server setup-ldap --verbose'
  cmd_string << ' --ldap-force-setup' unless is_old_version
  cmd_string << " --ldap-url=#{ldap_url}" unless ldap_url.nil?
  cmd_string << " --ldap-secondary-url=#{ldap_secondary_url}" unless ldap_secondary_url.nil?
  cmd_string << " --ldap-ssl=#{ldap_ssl}" unless ldap_ssl.nil?
  cmd_string << " --ldap-type=#{ldap_type}" unless (ldap_type.nil? || is_old_version)
  cmd_string << " --ldap-user-class=#{ldap_user_class}" unless ldap_user_class.nil?
  cmd_string << " --ldap-user-attr=#{ldap_user_attr}" unless ldap_user_attr.nil?
  cmd_string << " --ldap-group-class=#{ldap_group_class}" unless ldap_group_class.nil?
  cmd_string << " --ldap-group-attr=#{ldap_group_attr}" unless ldap_group_attr.nil?
  cmd_string << " --ldap-member-attr=#{ldap_member_attr}" unless ldap_member_attr.nil?
  cmd_string << " --ldap-dn=#{ldap_dn}" unless ldap_dn.nil?
  cmd_string << " --ldap-base-dn=#{ldap_base_dn}" unless ldap_base_dn.nil?
  cmd_string << " --ldap-referral=#{ldap_referral}" unless ldap_referral.nil?
  cmd_string << " --ldap-bind-anonym=#{ldap_bind_anonym}" unless ldap_bind_anonym.nil?
  cmd_string << " --ldap-manager-dn=#{ldap_manager_dn}" unless ldap_manager_dn.nil?
  cmd_string << " --ldap-manager-password=#{ldap_manager_password}" unless ldap_manager_password.nil?
  cmd_string << ' --ldap-save-settings' if ldap_save_settings
  cmd_string << " --ldap-sync-username-collisions-behavior=#{ldap_collision}" unless ldap_collision.nil?
  cmd_string << " --ldap-force-lowercase-usernames=#{ldap_lowercase}" unless (ldap_lowercase.nil? || is_old_version)
  cmd_string << " --ldap-pagination-enabled=#{ldap_pagination}" unless (ldap_pagination.nil? || is_old_version)
  cmd_string << " --ambari-admin-username=#{ambari_login}" unless (ambari_login.nil? || is_old_version)
  cmd_string << " --ambari-admin-password=#{ambari_password}" unless (ambari_password.nil? || is_old_version)
  cmd_string << " --truststore-type=#{truststore_type}" unless truststore_type.nil?
  cmd_string << " --truststore-path=#{truststore_path}" unless truststore_path.nil?
  cmd_string << " --truststore-password=#{truststore_password}" unless truststore_password.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, "stderr: '#{stderr}'\nstdout: '#{stdout.strip}'" if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
ldap_type = params.fetch('ldap_type', 'AD')
ldap_url = params['ldap_url']
ldap_secondary_url = params['ldap_secondary_url']
ldap_ssl = params.fetch('ldap_ssl', 'false')
ldap_user_class = params.fetch('ldap_user_class', 'person')
ldap_user_attr = params.fetch('ldap_user_attr', 'sAMAccountName')
ldap_group_class = params.fetch('ldap_group_class', 'group')
ldap_group_attr = params.fetch('ldap_group_attr', 'cn')
ldap_member_attr = params.fetch('ldap_member_attr', 'member')
ldap_dn = params.fetch('ldap_dn', 'distunguishedName')
ldap_base_dn = params['ldap_base_dn']
ldap_referral = params.fetch('ldap_referral', 'follow')
ldap_bind_anonym = params.fetch('ldap_bind_anonym', 'false')
ldap_manager_dn = params['ldap_manager_dn']
ldap_manager_password = params['ldap_manager_password']
ldap_save_settings = params.fetch('ldap_save_settings', true)
ldap_collision = params.fetch('ldap_collision', 'convert')
ldap_lowercase = params['ldap_lowercase']
ldap_pagination = params.fetch('ldap_pagination', true)
ambari_login = params.fetch('admin_user', 'admin')
ambari_password = params['admin_password']
if ldap_ssl == true
  truststore_type = params.fetch('truststore_type', 'jks')
  truststore_path = params['truststore_path']
  truststore_password = params['truststore_password']
end

begin
  result = ambari_setup_ldap(
    ldap_type, ldap_url,
    ldap_secondary_url,
    ldap_ssl,
    ldap_user_class,
    ldap_user_attr,
    ldap_group_class,
    ldap_group_attr,
    ldap_member_attr,
    ldap_dn,
    ldap_base_dn,
    ldap_referral,
    ldap_bind_anonym,
    ldap_manager_dn,
    ldap_manager_password,
    ldap_save_settings,
    ldap_collision,
    ldap_lowercase,
    ldap_pagination,
    ambari_login,
    ambari_password,
    truststore_type,
    truststore_path,
    truststore_password
  )

  puts result
  exit 0
rescue Puppet::Error => e
  puts(status: 'failure', error: e.message)
  exit 1
end
