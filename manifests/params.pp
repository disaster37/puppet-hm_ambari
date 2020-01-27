class hm_ambari::params {

  # Global parameters
  $ambari_version = '2.7.3.0'
  $manage_repo = true
  $manage_java = true
  $global_resources_ensure  = 'present'
  $service_provider = 'systemd'



  # Agent parameters
  $agent_package_ensure = 'present'
  $agent_service_ensure = 'running'
  $agent_service_enable = true
  $ambari_server_port = '8440'
  $ambari_server_secure_port = '8441'
  $ambari_server = 'localhost'
  $ambari_agent_alias = undef
  $ambari_agent_settings = {}

  # Server parameters
  $server_package_ensure = 'present'
  $server_service_ensure = 'stopped'
  $server_service_enable = true
  $server_agent_ssl = false
  $ambari_server_settings = {}
  $disable_python_security = true
  $ambari_cli_version = '1.0.4-2'
  $install_ambari_cli = true
  $hdp_privileges = {}
  $hdp_repositories = {}
  $hdp_blueprint = {}
  $hdp_hosts_template = {}
}

