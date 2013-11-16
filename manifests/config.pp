# Class: mesos::config
#
# This module manages the mesos configuration directories
#
# Parameters: None
#
# Actions: None
#
# Requires: mesos::install, mesos
#
# Sample Usage: include mesos::config
#
class mesos::config(
  $log_dir,
  $conf_dir,
  $owner,
  $group,
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

  file { "#{conf_dir}/master.conf":
    require => Package['mesos'],
    content => template('mesos/master.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644'
  }

  file { '/etc/default/mesos':
    require => Package['mesos'],
    content => template('mesos/default.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644'
  }

}

