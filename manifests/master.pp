# Class: mesos::master
#
# This module manages Mesos master - installs Mesos package
# and starts master service.
#
# Parameters: None
#
#
# Sample Usage:
#
# class{ 'mesos::master': }
#
class mesos::master(
  $enable         = true,
  $whitelist      = '*',
  $cluster        = 'mesos',
  $conf_dir       = '/etc/mesos-master',
  $conf_file      = '/etc/default/mesos-master',
  $master_port    = $mesos::master_port,
  $zookeeper      = $mesos::zookeeper,
  $owner          = $mesos::owner,
  $group          = $mesos::group,
  $listen_address = $mesos::listen_address,
) inherits mesos {

  file { $conf_dir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
  }

  file { $conf_file:
    ensure  => present,
    content => template('mesos/master.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => [File[$conf_dir], Package['mesos']],
  }

  # Install mesos-master service
  mesos::service { 'master':
    enable     => $enable,
    require    => File[$conf_file],
  }
}
