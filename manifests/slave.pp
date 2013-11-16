# Class: mesos::slave
#
# This module manages mesos slave
#
# Parameters: None
#
# Actions: None
#
# Requires: mesos::install
#
# Sample Usage: include mesos::slave
#
class mesos::slave (
  $enable   = true,
  $start    = 'yes',
  $owner    = $mesos::owner,
  $group    = $mesos::group,
  $conf_dir = $mesos::conf_dir,
) inherits mesos {

  file { "${conf_dir}/slave.conf":
    ensure  => 'present',
    content => template('mesos/slave.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => Package['mesos'],
  }

  # Install mesos-slave service
  mesos::service { 'slave':
    start      => $start,
    enable     => $enable,
    conf_dir   => $conf_dir,
    require    => File["${conf_dir}/slave.conf"],
  }

}
