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
# Copyright 2013 Tomas Barton
#
class mesos(
  $ensure       = hiera('mesos::version', 'present')
) {

  # human readable name for cluster
  $cluster      = hiera('mesos::cluster', '')
  $slaves       = hiera('mesos::slaves', '*')
  $whitelist    = hiera('mesos::whitelist', '*')


  # master and slave creates separate logs automatically
  # TODO: currently not used
  $log_dir      = hiera('mesos::log_dir', '/var/log/mesos')
  $conf_dir     = hiera('mesos::conf_dir', '/etc/mesos')

  # slave
  # e.g. zk://localhost:2181/mesos
  $zk           = hiera('mesos::zk', undef)
  # if "zk" is empty, master value is used
  $master       = hiera('mesos::master', '127.0.0.1')
  $master_port  = hiera('mesos::master_port', '5050')
  $slave_port   = hiera('mesos::slave_port', '5051')
  $work_dir     = hiera('mesos::work_dir', '/tmp/mesos')
  $checkpoint   = hiera('mesos::checkpoint', false)
  $owner        = hiera('mesos::owner', 'root')
  $group        = hiera('mesos::group', 'root')

#  include mesos::install
#  include mesos::config
  class {'mesos::install':
    ensure => $ensure,
  }

  class {'mesos::config':
    log_dir  => $log_dir,
    conf_dir => $conf_dir,
    owner    => $owner,
    group    => $group,
    require  => Class['mesos::install']
  }

}
