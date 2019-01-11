require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'ambari server class:' do
  describe 'Deploy ambari server with some hdp config files for task deployment' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'hm_ambari::server':

          ambari_server_settings => {
            '' => {
              'server.startup.web.timeout' => 120,
              'ambari.post.user.creation.hook.enabled' => true,
              'ambari.post.user.creation.hook' => '/var/lib/ambari-server/resources/scripts/post-user-creation-hook.sh',
              'authentication.ldap.username.forceLowercase' => true,
            }
          },
          hdp_repositories => {
            name => "HDP-2.6.4.0",
            version => "2.6.4.0",
            repositories => [
              {
                repositoryName => 'HDP',
                repositoryId => 'HDP-2.6.4.0',
                repositoryBaseUrl => 'http://10.221.78.61:5080/hdp/HDP-2.6.4.0',
              },
              {
                repositoryName => 'HDP-UTILS',
                repositoryId => 'HDP-UTILS-1.1.0.22',
                repositoryBaseUrl => 'http://10.221.78.61:5080/hdp-utils/HDP-UTILS-1.1.0.22',
              },
              {
                repositoryName => 'HDP-GPL',
                repositoryId => 'HDP-GPL-2.6.4.0',
                repositoryBaseUrl => 'http://10.221.78.61:5080/hdp-gpl/HDP-GPL-2.6.4.0',
              },
              {
                repositoryName => 'HDP-SOLR',
                repositoryId => 'HDP-SOLR-2.6-100',
                repositoryBaseUrl => 'http://10.221.78.61:5080/hdp-search/HDP-SOLR-2.6-100',
              },
              {
                repositoryName => 'HDP-UTILS-GPL',
                repositoryId => 'HDP-UTILS-GPL-1.1.0.22',
                repositoryBaseUrl => 'http://10.221.78.61:5080/hdp-utils-gpl/HDP-UTILS-GPL-1.1.0.22',
              },
            ]
          },
          hdp_privileges => {

            'clusterName' => 'test',
            'privileges' => [
              {
                permission => 'CLUSTER.ADMINISTRATOR',
                type =>  'GROUP',
                name => 'hm_etl_outils'
              }
            ]
          },
          hdp_hosts_template => {

            'blueprint' => 'test',
            'config_recommendation_strategy' => 'ALWAYS_APPLY_DONT_OVERRIDE_CUSTOM_VALUES',
            'host_groups' => [
              {
                name => 'master0',
                hosts => [
                  {
                    fqdn => 'centos-7-x64'
                  }
                ],
              }
            ]
          },
          hdp_blueprint =>  {
            'configurations' => [
              {
                'ams-grafana-env' => {
                  properties => {
                    'metrics_grafana_password' => '@SihmBigdata37!'
                  }
                }
              },
              {
                'hive-site' => {
                  properties => {
                    'javax.jdo.option.ConnectionUserName' => 'hive',
                    'javax.jdo.option.ConnectionPassword' => 'hive',
                    'javax.jdo.option.ConnectionDriverName' => 'org.postgresql.Driver',
                    'javax.jdo.option.ConnectionURL' => 'jdbc:postgresql://internal0:5432/hive'
                  }
                }
              },
              {
                'hive-env' => {
                  properties => {
                    'hive_database' => 'Existing PostgreSQL Database',
                    'hive_database_name' => 'hive',
                    'hive_database_type' => 'postgres'
                  }
                }
              },
              {
                'oozie-env' => {
                  properties => {
                    'oozie_database' => 'Existing PostgreSQL Database'
                  }
                }
              },
              {
                'oozie-site' => {
                  properties => {
                    'oozie.service.JPAService.jdbc.driver' => 'org.postgresql.Driver',
                    'oozie.service.JPAService.jdbc.password' => 'oozie',
                    'oozie.service.JPAService.jdbc.url' => 'jdbc:postgresql://internal0:5432/oozie',
                    'oozie.service.JPAService.jdbc.username' => 'oozie',
                    'oozie.zookeeper.connection.string' => '%HOSTGROUP::master0%:2181,%HOSTGROUP::master1%:2181,%HOSTGROUP::master2%:2181',
                    'oozie.services.ext' => 'org.apache.oozie.service.ZKLocksService,org.apache.oozie.service.ZKXLogStreamingService,org.apache.oozie.service.ZKJobsConcurrencyService',
                    'oozie.base.url' => 'http://%HOSTGROUP::master1%:11000/oozie'
                  }
                }
              },
              {
                'admin-properties' => {
                  properties => {
                    'SQL_CONNECTOR_JAR' => '/usr/share/java/postgresql-jdbc.jar',
                    'DB_FLAVOR' => 'POSTGRES',
                    'db_host' => 'internal0',
                    'db_name' => 'ranger',
                    'db_user' => 'ranger',
                    'db_password' => 'ranger',
                    'db_root_password' => ''
                  }
                }
              },
              {
                'ranger-admin-site' => {
                  properties => {
                    'ranger.jpa.jdbc.driver' => 'org.postgresql.Driver',
                    'ranger.jpa.jdbc.url' => 'jdbc:postgresql://internal0:5432/ranger'
                  }
                }
              },
              {
                'ranger-env' => {
                  properties => {
                    'ranger-hdfs-plugin-enabled' => 'Yes',
                    'ranger-hbase-plugin-enabled' => 'Yes',
                    'ranger-hive-plugin-enabled' => 'Yes',
                    'ranger-knox-plugin-enabled' => 'Yes',
                    'ranger-yarn-plugin-enabled' => 'Yes',
                    'ranger-atlas-plugin-enabled' => 'Yes',
                    'ranger-storm-plugin-enabled' => 'No',
                    'ranger-kafka-plugin-enabled' => 'No',
                    'ranger_admin_password' => '@SihmBigdata37!',
                    'xasecure.audit.destination.db' => 'false',
                    'xasecure.audit.destination.solr' => 'true',
                    'xasecure.audit.destination.hdfs' => 'false',
                    'is_solrCloud_enabled' => 'true',
                    'create_db_dbuser' => 'false'
                  }
                }
              },
              {
                'knox-env' => {
                  properties => {
                    'knox_master_secret' => '@SihmBigdata37!',
                    'gateway.port' => '8443'
                  }
                }
              },
              {
                'core-site' => {
                  properties => {
                    'fs.defaultFS' => 'hdfs://cluster',
                    'ha.zookeeper.quorum' => '%HOSTGROUP::master0%:2181,%HOSTGROUP::master1%:2181,%HOSTGROUP::master2%:2181'
                  }
                }
              },
              {
                'hdfs-site' => {
                  properties => {
                    'dfs.client.failover.proxy.provider.cluster' => 'org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider',
                    'dfs.ha.automatic-failover.enabled' => 'true',
                    'dfs.ha.fencing.methods' => 'shell(/bin/true)',
                    'dfs.ha.namenodes.cluster' => 'nn1,nn2',
                    'dfs.namenode.http-address' => '%HOSTGROUP::master0%:50070',
                    'dfs.namenode.http-address.cluster.nn1' => '%HOSTGROUP::master0%:50070',
                    'dfs.namenode.http-address.cluster.nn2' => '%HOSTGROUP::master1%:50070',
                    'dfs.namenode.https-address' => '%HOSTGROUP::master0%:50470',
                    'dfs.namenode.https-address.cluster.nn1' => '%HOSTGROUP::master0%:50470',
                    'dfs.namenode.https-address.cluster.nn2' => '%HOSTGROUP::master1%:50470',
                    'dfs.namenode.rpc-address.cluster.nn1' => '%HOSTGROUP::master0%:8020',
                    'dfs.namenode.rpc-address.cluster.nn2' => '%HOSTGROUP::master1%:8020',
                    'dfs.namenode.shared.edits.dir' => 'qjournal://%HOSTGROUP::master0%:8485;%HOSTGROUP::master1%:8485;%HOSTGROUP::master2%:8485/cluster',
                    'dfs.nameservices' => 'cluster'
                  }
                }
              },
              {
                'yarn-site' => {
                  properties => {
                    'hadoop.registry.rm.enabled' => 'false',
                    'hadoop.registry.zk.quorum' => '%HOSTGROUP::master0%:2181,%HOSTGROUP::master1%:2181,%HOSTGROUP::master2%:2181',
                    'yarn.log.server.url' => 'http://%HOSTGROUP::master0%:19888/jobhistory/logs',
                    'yarn.resourcemanager.address' => '%HOSTGROUP::master2%:8050',
                    'yarn.resourcemanager.admin.address' => '%HOSTGROUP::master2%:8141',
                    'yarn.resourcemanager.cluster-id' => 'yarn-cluster',
                    'yarn.resourcemanager.ha.automatic-failover.zk-base-path' => '/yarn-leader-election',
                    'yarn.resourcemanager.ha.enabled' => 'true',
                    'yarn.resourcemanager.ha.rm-ids' => 'rm1,rm2',
                    'yarn.resourcemanager.hostname' => '%HOSTGROUP::master2%',
                    'yarn.resourcemanager.recovery.enabled' => 'true',
                    'yarn.resourcemanager.resource-tracker.address' => '%HOSTGROUP::master2%:8025',
                    'yarn.resourcemanager.scheduler.address' => '%HOSTGROUP::master2%:8030',
                    'yarn.resourcemanager.store.class' => 'org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore',
                    'yarn.resourcemanager.webapp.address' => '%HOSTGROUP::master2%:8088',
                    'yarn.resourcemanager.webapp.https.address' => '%HOSTGROUP::master2%:8090',
                    'yarn.timeline-service.address' => '%HOSTGROUP::master2%:10200',
                    'yarn.timeline-service.webapp.address' => '%HOSTGROUP::master2%:8188',
                    'yarn.timeline-service.webapp.https.address' => '%HOSTGROUP::master2%:8190',
                    'yarn.resourcemanager.hostname.rm1' => '%HOSTGROUP::master1%',
                    'yarn.resourcemanager.hostname.rm2' => '%HOSTGROUP::master2%',
                    'yarn.resourcemanager.zk-address' => '%HOSTGROUP::master0%:2181,%HOSTGROUP::master1%:2181,%HOSTGROUP::master2%:2181'
                  }
                }
              },
              {
                'hbase-site' => {
                  properties => {
                    'hbase.rootdir' => 'hdfs://cluster/hbase'
                  }
                }
              },
              {
                'application-properties' => {
                  properties => {
                    'atlas.rest.address' => 'http://%HOSTGROUP::master1%:21000,http://%HOSTGROUP::master2%:21000',
                    'atlas.server.ha.enabled' => 'true',
                    'atlas.server.ids' => 'id1,id2',
                    'atlas.server.address.id1' => '%HOSTGROUP::master1%:21000',
                    'atlas.server.address.id2' => '%HOSTGROUP::master2%:21000',
                    'atlas.server.bind.address' => '%HOSTGROUP::master1%'
                  }
                }
              }
            ],
            'host_groups' => [
              {
                name => 'master0',
                configurations => [],
                components => [
                  {name => 'ZOOKEEPER_CLIENT'},
                  {name => 'ZOOKEEPER_SERVER'},
                  {name => 'INFRA_SOLR'},
                  {name => 'INFRA_SOLR_CLIENT'},
                  {name => 'METRICS_MONITOR'},
                  {name => 'NAMENODE'},
                  {name => 'HDFS_CLIENT'},
                  {name => 'HBASE_CLIENT'},
                  {name => 'YARN_CLIENT'},
                  {name => 'MAPREDUCE2_CLIENT'},
                  {name => 'SPARK2_THRIFTSERVER'},
                  {name => 'SPARK2_CLIENT'},
                  {name => 'TEZ_CLIENT'},
                  {name => 'HIVE_SERVER'},
                  {name => 'HIVE_METASTORE'},
                  {name => 'HIVE_CLIENT'},
                  {name => 'WEBHCAT_SERVER'},
                  {name => 'HCAT'},
                  {name => 'ATLAS_CLIENT'},
                  {name => 'OOZIE_CLIENT'},
                  {name => 'PIG'},
                  {name => 'SLIDER'},
                  {name => 'KNOX_GATEWAY'},
                  {name => 'ZKFC'},
                  {name => 'JOURNALNODE'},
                  {name => 'HISTORYSERVER'}
                ],
                cardinality => '1'
              },
              {
                name => 'master1',
                configurations => [],
                components => [
                  {name => 'ZOOKEEPER_CLIENT'},
                  {name => 'ZOOKEEPER_SERVER'},
                  {name => 'INFRA_SOLR_CLIENT'},
                  {name => 'METRICS_MONITOR'},
                  {name => 'METRICS_GRAFANA'},
                  {name => 'METRICS_COLLECTOR'},
                  {name => 'NAMENODE'},
                  {name => 'HDFS_CLIENT'},
                  {name => 'HBASE_CLIENT'},
                  {name => 'HBASE_MASTER'},
                  {name => 'YARN_CLIENT'},
                  {name => 'RESOURCEMANAGER'},
                  {name => 'MAPREDUCE2_CLIENT'},
                  {name => 'SPARK2_THRIFTSERVER'},
                  {name => 'SPARK2_CLIENT'},
                  {name => 'SPARK2_JOBHISTORYSERVER'},
                  {name => 'TEZ_CLIENT'},
                  {name => 'HIVE_SERVER'},
                  {name => 'HIVE_METASTORE'},
                  {name => 'HIVE_CLIENT'},
                  {name => 'WEBHCAT_SERVER'},
                  {name => 'HCAT'},
                  {name => 'ATLAS_CLIENT'},
                  {name => 'ATLAS_SERVER'},
                  {name => 'OOZIE_CLIENT'},
                  {name => 'OOZIE_SERVER'},
                  {name => 'RANGER_ADMIN'},
                  {name => 'RANGER_TAGSYNC'},
                  {name => 'RANGER_USERSYNC'},
                  {name => 'KNOX_GATEWAY'},
                  {name => 'ZKFC'},
                  {name => 'JOURNALNODE'}
                ],
                cardinality => '0'
              },
              {
                name => 'master2',
                configurations => [],
                components => [
                  {name => 'ZOOKEEPER_CLIENT'},
                  {name => 'ZOOKEEPER_SERVER'},
                  {name => 'INFRA_SOLR_CLIENT'},
                  {name => 'METRICS_MONITOR'},
                  {name => 'HDFS_CLIENT'},
                  {name => 'HBASE_CLIENT'},
                  {name => 'HBASE_MASTER'},
                  {name => 'YARN_CLIENT'},
                  {name => 'MAPREDUCE2_CLIENT'},
                  {name => 'SPARK2_THRIFTSERVER'},
                  {name => 'SPARK2_CLIENT'},
                  {name => 'TEZ_CLIENT'},
                  {name => 'HIVE_SERVER'},
                  {name => 'HIVE_CLIENT'},
                  {name => 'WEBHCAT_SERVER'},
                  {name => 'HCAT'},
                  {name => 'ATLAS_CLIENT'},
                  {name => 'ATLAS_SERVER'},
                  {name => 'OOZIE_CLIENT'},
                  {name => 'OOZIE_SERVER'},
                  {name => 'KNOX_GATEWAY'},
                  {name => 'JOURNALNODE'},
                  {name => 'RESOURCEMANAGER'},
                  {name => 'APP_TIMELINE_SERVER'}
                ],
                cardinality => '0'
              },
              {
                name => 'services',
                configurations => [],
                components => [
                  {name => 'ZOOKEEPER_CLIENT'},
                  {name => 'INFRA_SOLR_CLIENT'},
                  {name => 'METRICS_MONITOR'},
                  {name => 'HDFS_CLIENT'},
                  {name => 'HBASE_CLIENT'},
                  {name => 'YARN_CLIENT'},
                  {name => 'MAPREDUCE2_CLIENT'},
                  {name => 'SPARK2_CLIENT'},
                  {name => 'TEZ_CLIENT'},
                  {name => 'HIVE_CLIENT'},
                  {name => 'HCAT'},
                  {name => 'ATLAS_CLIENT'},
                  {name => 'OOZIE_CLIENT'},
                  {name => 'KAFKA_BROKER'}
                ],
                cardinality => '0'
              },
              {
                name => 'ingests',
                configurations => [],
                components => [
                  {name => 'ZOOKEEPER_CLIENT'},
                  {name => 'INFRA_SOLR_CLIENT'},
                  {name => 'METRICS_MONITOR'},
                  {name => 'HDFS_CLIENT'},
                  {name => 'HBASE_CLIENT'},
                  {name => 'YARN_CLIENT'},
                  {name => 'MAPREDUCE2_CLIENT'},
                  {name => 'SPARK2_CLIENT'},
                  {name => 'TEZ_CLIENT'},
                  {name => 'HIVE_CLIENT'},
                  {name => 'HCAT'},
                  {name => 'ATLAS_CLIENT'},
                  {name => 'OOZIE_CLIENT'},
                  {name => 'KAFKA_BROKER'}
                ],
                cardinality => '0'
              },
              {
                name => 'workers',
                configurations => [],
                components => [
                  {name => 'ZOOKEEPER_CLIENT'},
                  {name => 'INFRA_SOLR_CLIENT'},
                  {name => 'METRICS_MONITOR'},
                  {name => 'DATANODE'},
                  {name => 'HDFS_CLIENT'},
                  {name => 'HBASE_CLIENT'},
                  {name => 'HBASE_REGIONSERVER'},
                  {name => 'YARN_CLIENT'},
                  {name => 'NODEMANAGER'},
                  {name => 'MAPREDUCE2_CLIENT'},
                  {name => 'SPARK2_CLIENT'},
                  {name => 'TEZ_CLIENT'},
                  {name => 'HIVE_CLIENT'},
                  {name => 'HCAT'},
                  {name => 'ATLAS_CLIENT'},
                  {name => 'OOZIE_CLIENT'}
                ],
                cardinality => '0'
              }
            ],

            'Blueprints' => {
              'stack_name' => 'HDP',
              'stack_version' => '2.6'
            }
          }
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end

    describe file('/etc/ambari-server/conf/ambari.properties') do
      it { is_expected.to contain 'ambari.post.user.creation.hook=/var/lib/ambari-server/resources/scripts/post-user-creation-hook.sh' }
      it { is_expected.to contain 'authentication.ldap.username.forceLowercase=true' }
      it { is_expected.to contain 'server.startup.web.timeout=120' }
    end

    describe file('/etc/ambari-server/conf/api/repositories.json') do
      it { is_expected.to be_file }
    end
    describe file('/etc/ambari-server/conf/api/blueprint.json') do
      it { is_expected.to be_file }
    end
    describe file('/etc/ambari-server/conf/api/hoststemplate.json') do
      it { is_expected.to be_file }
    end
    describe file('/etc/ambari-server/conf/api/privileges.json') do
      it { is_expected.to be_file }
    end
  end
end
