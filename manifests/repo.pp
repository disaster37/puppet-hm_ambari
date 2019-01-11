class hm_ambari::repo {


    $ambari_version = $hm_ambari::ambari_version
    $temp_version = split($ambari_version, '\.')
    $repo_version = $temp_version[0]

    if $hm_ambari::global_resources_ensure == 'present' {
        $repo_ensure = 'file'
        include wget

        wget::fetch { 'ambari_yum_repo':
          source      => "http://public-repo-1.hortonworks.com/ambari/centos${::operatingsystemmajrelease}/${repo_version}.x/updates/${ambari_version}/ambari.repo",
          destination => '/etc/yum.repos.d/ambari.repo',
          execuser    => 'root',
          mode        => '0644',
          cache_dir   => '/var/cache/wget'
        }
    }
    else {
        file {'/etc/yum.repos.d/ambari.repo':
            ensure => 'absent'
        }
    }
}