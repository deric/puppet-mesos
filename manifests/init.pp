# == Class: mesos
#
# This module manages mesos installation
#
# === Examples
#
#      class{ 'mesos':
#         zookeeper => ['192.168.1.1:2181', '192.168.1.1:2181'],
#      }
#
# === Parameters
#
#  [*zookeeper*]
#    An array of ZooKeeper ip's (with port) (will be converted to a zk url)
#
#  [*zookeeper_path*]
#    Mesos namespace in ZooKeeper (last part of the zk:// URL, e.g. `zk://192.168.1.1/mesos`)
#
#  [*master*]
#    If `zookeeper` is empty, master value is used
#
#  [*listen_address*]
#    Could be a fact like `$::ipaddress` or explicit ip address (String).
#
# === Authors
#
# Tomas Barton <barton.tomas@gmail.com>
#
# === Copyright
#
# Copyright 2013-2016 Tomas Barton
#
class mesos(
  $ensure          = 'present',
  # if version is not defined, ensure will be used
  $version         = undef,
  # master and slave creates separate logs automatically
  # TODO: currently not used
  $log_dir         = undef,
  $conf_dir        = '/etc/mesos',
  $conf_file       = '/etc/default/mesos',
  $manage_zk_file  = true,
  $manage_service  = true,
  $zookeeper       = [],
  $zk_path         = 'mesos',
  $zk_default_port = 2181,
  $master          = '127.0.0.1',
  $master_port     = 5050,
  $owner           = 'root',
  $group           = 'root',
  $listen_address  = undef,
  $repo            = undef,
  $env_var         = {},
  $ulimit          = 8192,
  $manage_python   = false,
  $python_package  = 'python',
  $force_provider  = undef, #temporary workaround for starting services
) {
  validate_hash($env_var)
  validate_bool($manage_zk_file)
  validate_bool($manage_service)

  if !empty($zookeeper) {
    $zookeeper_url = zookeeper_servers_url($zookeeper, $zk_path, $zk_default_port)
  }

  $mesos_ensure = $version ? {
    undef    => $ensure,
    default  => $version,
  }

  class {'mesos::install':
    ensure                  => $mesos_ensure,
    repo_source             => $repo,
    manage_python           => $manage_python,
    python_package          => $python_package,
    remove_package_services => $force_provider == 'none',
  }

  class {'mesos::config':
    log_dir        => $log_dir,
    conf_dir       => $conf_dir,
    conf_file      => $conf_file,
    manage_zk_file => $manage_zk_file,
    owner          => $owner,
    group          => $group,
    zookeeper_url  => $zookeeper_url,
    env_var        => $env_var,
    ulimit         => $ulimit,
    require        => Class['mesos::install']
  }

}
