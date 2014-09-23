# Class: mesos::config
#
# This module manages the mesos configuration directories
#
# Parameters:
#  [*log_dir*]  - directory for logging (default: /var/log/mesos)
#  [*conf_dir*] - directory for configuration files (default: /etc/mesos)
#  [*owner*]    - owner of configuration files
#  [*group*]    - group of configuration files
#
# This class should not be included directly,
# always use 'mesos::slave' or 'mesos:master'
#
class mesos::config(
  $log_dir   = '/var/log/mesos',
  $ulimit    = 8192,
  $conf_dir  = '/etc/mesos',
  $owner     = 'root',
  $group     = 'root',
  $zookeeper = '',
  $env_var   = {},
){

  file { $log_dir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
  }

  file { $conf_dir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
  }

  file { '/etc/default/mesos':
    ensure  => 'present',
    content => template('mesos/default.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => Package['mesos'],
  }

  # file containing only zookeeper URL
  file { '/etc/mesos/zk':
    ensure  => empty($zookeeper) ? {
      true  => absent,
      false => present,
    },
    content => $zookeeper,
    owner   => $owner,
    group   => $group,
  }

}
