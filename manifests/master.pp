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
  $enable      = true,
  $whitelist   = '*',
  $cluster     = 'mesos',
  $master_port = $mesos::master_port,
  $zookeeper   = $mesos::zookeeper,
  $owner       = $mesos::owner,
  $group       = $mesos::group,
  $conf_dir    = $mesos::conf_dir,
) inherits mesos {

  file { "/etc/default/mesos-master":
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
    conf_dir   => $conf_dir,
    require    => File["/etc/default/mesos-master"],
  }
}
