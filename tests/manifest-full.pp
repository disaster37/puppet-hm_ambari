class { 'ambari':
  deploy_ambari_server => true,
  ambari_server_status => 'enabled',
  ambari_agent_status  => 'enabled',
  deploy_ambari_agent  => true
}