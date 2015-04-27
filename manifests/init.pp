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
  # if version is not defined, ensure will be used
  $version        = undef,
  # master and slave creates separate logs automatically
  # TODO: currently not used
  $log_dir        = '/var/log/mesos',
  $conf_dir       = '/etc/mesos',
  $manage_zk_file = true,
  # e.g. zk://localhost:2181/mesos
  $zookeeper      = '',
  # if "zk" is empty, master value is used
  $master         = '127.0.0.1',
  $master_port    = 5050,
  $owner          = 'root',
  $group          = 'root',
  # could be a fact like $::ipaddress or explicit ip address
  $listen_address = undef,
  $repo           = undef,
  $env_var        = {},
  $ulimit         = 8192,
  $manage_python  = false,
  $python_package = 'python',
) {
  validate_hash($env_var)

  $mesos_ensure = $version ? {
    undef    => $ensure,
    default  => $version,
  }

  class {'mesos::install':
    ensure         => $mesos_ensure,
    repo_source    => $repo,
    manage_python  => $manage_python,
    python_package => $python_package,
  }

  class {'mesos::config':
    log_dir        => $log_dir,
    conf_dir       => $conf_dir,
    manage_zk_file => $manage_zk_file,
    owner          => $owner,
    group          => $group,
    zookeeper      => $zookeeper,
    env_var        => $env_var,
    ulimit         => $ulimit,
    require        => Class['mesos::install']
  }

}
