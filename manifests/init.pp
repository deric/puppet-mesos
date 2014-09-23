# == Class: mesos
#
# This module manages mesos installation
#
# === Examples
#
#      class{ 'mesos::master': }
#  or
#      class{ 'mesos:slave': }
#
#
# === Authors
#
# Tomas Barton <barton.tomas@gmail.com>
#
# === Copyright
#
# Copyright 2013-2014 Tomas Barton
#
class mesos(
  $ensure         = 'present',
  $version        = undef,
  # master and slave creates separate logs automatically
  # TODO: currently not used
  $log_dir        = '/var/log/mesos',
  $conf_dir       = '/etc/mesos',
  # e.g. zk://localhost:2181/mesos
  $zookeeper      = '',
  # if "zk" is empty, master value is used
  $master         = '127.0.0.1',
  $master_port    = 5050,
  $owner          = 'root',
  $group          = 'root',
  $listen_address = $::ipaddress,
  $repo           = undef,
  $env_var        = {},
) {
  validate_hash($env_var)

  $mesos_ensure = $version ? {
    undef    => $ensure,
    default  => $version,
  }

  class {'mesos::install':
    ensure      => $mesos_ensure,
    repo_source => $repo,
  }

  class {'mesos::config':
    log_dir   => $log_dir,
    conf_dir  => $conf_dir,
    owner     => $owner,
    group     => $group,
    zookeeper => $zookeeper,
    env_var   => $env_var,
    require   => Class['mesos::install']
  }

}
