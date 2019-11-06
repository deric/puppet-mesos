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
#  [*ensure*]
#   Package ensure present|absent
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
#  [*single_role*]
#    When enabled each machine is expected to run either master or slave service.
#
# === Authors
#
# Tomas Barton <barton.tomas@gmail.com>
#
# === Copyright
#
# Copyright 2013-2018 Tomas Barton
#
class mesos(
  String                                  $ensure              = 'present',
  # if version is not defined, ensure will be used
  Optional[String]                        $version = undef,
  # master and slave creates separate logs automatically
  # TODO: currently not used
  Optional[String]                        $log_dir = undef,
  String                                  $conf_dir            = '/etc/mesos',
  String                                  $conf_file           = '/etc/default/mesos',
  Boolean                                 $manage_zk_file      = true,
  Boolean                                 $manage_service      = true,
  Optional[Variant[String,Array[String]]] $zookeeper           = [],
  String                                  $zk_path             = 'mesos',
  Integer                                 $zk_default_port     = 2181,
  String                                  $master              = '127.0.0.1',
  Integer                                 $master_port         = 5050,
  String                                  $owner               = 'root',
  String                                  $group               = 'root',
  Optional[String]                        $listen_address      = undef,
  Boolean                                 $manage_repo         = true,
  Variant[String,Hash]                    $repo                = 'mesosphere',
  Hash                                    $env_var             = {},
  Integer                                 $ulimit              = 8192,
  Boolean                                 $manage_python       = false,
  String                                  $python_package      = 'python',
  Optional[String]                        $force_provider      = undef, #temporary workaround for starting services
  Boolean                                 $use_hiera           = false,
  Boolean                                 $single_role         = true,
  Optional[String]                        $service_provider    = $::mesos::params::service_provider,
  Boolean                                 $manage_service_file = $::mesos::params::manage_service_file,
  String                                  $systemd_path        = $::mesos::params::systemd_path,
) inherits ::mesos::params {
  if !empty($zookeeper) {
    if is_string($zookeeper) {
      warning('\$zookeeper parameter should be an array of IP addresses, please update your configuration.')
    }
    $zookeeper_url = zookeeper_servers_url($zookeeper, $zk_path, $zk_default_port)
  } else {
    $zookeeper_url = undef
  }

  $mesos_ensure = $version ? {
    undef    => $ensure,
    default  => $version,
  }

  class {'mesos::install':
    ensure                  => $mesos_ensure,
    repo_source             => $repo,
    manage_repo           => $manage_repo,
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
