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
class mesos::config {
  require mesos::install
  include mesos::params

  file { '/etc/mesos/conf/mesos.conf':
    require => Package['mesos'],
    content => template('mesos/mesos.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }

  file { '/etc/default/mesos':
    require => Package['mesos'],
    content => template('mesos/default.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }

}

