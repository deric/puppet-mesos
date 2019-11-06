# Class: mesos::config
#
# This class manages the mesos configuration directories
#
# Parameters:
#  [*log_dir*]        - directory for logging, (default: '/var/log/mesos')
#  [*conf_dir*]       - directory for configuration files (default: /etc/mesos)
#  [*manage_zk_file*] - flag whether module manages /etc/mesos/zk (default: true)
#  [*owner*]          - owner of configuration files
#  [*group*]          - group of configuration files
#  [*zookeeper_url*]  - string of ZooKeeper servers e.g. `zk://10.0.0.1/mesos`
#
# This class should not be included directly,
# always use 'mesos::slave' or 'mesos:master'
#
class mesos::config(
  Optional[String]  $log_dir        = undef,
  Integer           $ulimit         = 8192,
  String            $conf_dir       = '/etc/mesos',
  String            $conf_file      = '/etc/default/mesos',
  Boolean           $manage_zk_file = true,
  String            $owner          = 'root',
  String            $group          = 'root',
  Hash              $env_var        = {},
  Optional[String]  $zookeeper_url  = undef,
){

  File {
    owner  => $owner,
    group  => $group,
  }

  if $log_dir {
    file { $log_dir:
      ensure => directory,
    }
  }

  file { $conf_dir:
    ensure => directory,
  }

  file { $conf_file:
    ensure  => 'present',
    content => template('mesos/default.erb'),
    mode    => '0644',
    require => Package['mesos'],
  }

  if $manage_zk_file {
    # file containing only zookeeper URL
    file { '/etc/mesos/zk':
      ensure  => empty($zookeeper_url) ? {
        true  => absent,
        false => present,
      },
      content => $zookeeper_url,
    }
  }

}
