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

  file { '/etc/mesos/master.conf':
    require => Package['mesos'],
    content => template('mesos/master.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }
  
  file { '/etc/mesos/slave.conf':
    require => Package['mesos'],
    content => template('mesos/slave.erb'),
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

