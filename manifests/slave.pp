# Class: mesos::slave
#
# This module manages Mesos slave
#
# Parameters:
#  [*enable*]
#    Install Mesos slave service (default: true)
#
#  [*master*]
#    IP address of Mesos master (default: localhost)
#
#  [*master_port*]
#    Mesos master's port (default 5050)
#
#  [*zookeeper*]
#    Zookeeper URL string (which keeps track of current Mesos master)
#
#  [*work_dir*]
#    Directory for storing task's temporary files (default: /var/lib/mesos)
#
#  [*isolation*]
#    Isolation mechanism - either 'process' or 'cgroups' newer versions
#    of Mesos > 0.18 support isolation mechanism 'cgroups/cpu,cgroups/mem'
#    or posix/cpu,posix/mem
#
#  [*options*]
#    Any extra arguments that are not named here could be
#    stored in a hash:
#
#      options => { "key" => "value" }
#
#    (as value you can pass either string, boolean or numeric value)
#    which is serialized to disk and then passed to mesos-slave as:
#
#      --key=value
#
#  [*single_role*]
#    Currently Mesos packages ships with both mesos-master and mesos-slave
#    enabled by default. `single_role` assumes that you use only either of
#    those on one machine. Default: true (mesos-master service will be
#    disabled on slave node)
#
# Sample Usage:
#
# class{ 'mesos::slave':
#   master      => '10.0.0.1',
#   master_port => 5050,
# }
#

class mesos::slave (
  Boolean                                 $enable              = true,
  Integer                                 $port                = 5051,
  String                                  $work_dir            = '/var/lib/mesos',
  Boolean                                 $checkpoint          = false,
  Optional[String]                        $isolation           = undef,
  Stdlib::Absolutepath                    $conf_dir            = '/etc/mesos-slave',
  Stdlib::Absolutepath                    $conf_file           = '/etc/default/mesos-slave',
  Stdlib::Absolutepath                    $credentials_file    = '/etc/mesos/slave-credentials',
  String                                  $master              = $mesos::master,
  Integer                                 $master_port         = $mesos::master_port,
  Optional[Variant[String,Array[String]]] $zookeeper           = $mesos::zookeeper,
  String                                  $zk_path             = $mesos::zk_path,
  Integer                                 $zk_default_port     = $mesos::zk_default_port,
  String                                  $owner               = $mesos::owner,
  String                                  $group               = $mesos::group,
  Optional[String]                        $listen_address      = $mesos::listen_address,
  Boolean                                 $manage_service      = $mesos::manage_service,
  Hash                                    $env_var             = {},
  Hash                                    $cgroups             = {},
  Hash                                    $options             = {},
  Hash                                    $resources           = {},
  Hash                                    $attributes          = {},
  Optional[String]                        $principal           = undef,
  Optional[String]                        $secret              = undef,
  Boolean                                 $syslog_logger       = true,
  Boolean                                 $use_hiera           = $mesos::use_hiera,
  Boolean                                 $single_role         = $mesos::single_role,
  Optional[String]                        $service_provider    = $mesos::service_provider,
  Boolean                                 $manage_service_file = $::mesos::manage_service_file,
  String                                  $systemd_wants       = $::mesos::params::systemd_wants,
  String                                  $systemd_after       = $::mesos::params::systemd_after,
) inherits ::mesos {

  if !empty($zookeeper) {
    unless $zookeeper =~ Array {
      warning('\$zookeeper parameter should be an array of IP addresses, please update your configuration.')
    }
    $zookeeper_url = zookeeper_servers_url($zookeeper, $zk_path, $zk_default_port)
  }

  File {
    owner  => $owner,
    group  => $group,
  }

  file { $conf_dir:
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    require => Class['::mesos::install'],
    notify  => Service['mesos-slave'], # when key is removed we want to reload the service
  }

  file { "${conf_dir}/resources":
    ensure  => directory,
    require => File[$conf_dir],
    recurse => true,
    purge   => true,
  }

  file { "${conf_dir}/attributes":
    ensure  => directory,
    require => File[$conf_dir],
    recurse => true,
    purge   => true,
  }

  # stores properties in file structure
  create_resources(mesos::property,
    mesos_hash_parser($cgroups, 'slave', 'cgroups'),
    {
      owner  => $owner,
      group  => $group,
      dir    => $conf_dir,
      notify => Service['mesos-slave'],
    }
  )

  # for backwards compatibility, prefered way is specification via $options
  if !empty($isolation) {
    $isolator_options = {'isolation' => $isolation}
  } else {
    $isolator_options = {}
  }

  if (!empty($principal) and !empty($secret)) {
    $credentials_options = {'credential' => $credentials_file}
    $credentials_content = "{\"principal\": \"${principal}\", \"secret\": \"${secret}\"}"
    $credentials_ensure = file
  } else {
    $credentials_options = {}
    $credentials_content = undef
    $credentials_ensure = absent
  }

  if defined('$::mesos_version') {
    if ($::mesos_version != undef) and (versioncmp($::mesos_version, '0.28.0') >= 0)
      and $service_provider != 'systemd' {
      # otherwise rely on mesos-slave defaults
        $systemd_support = {'systemd_enable_support' => false}
    } else {
      $systemd_support = {}
    }
  } else {
    $systemd_support = {}
  }

  if $use_hiera {
    # In Puppet 3 automatic lookup won't merge options across multiple config
    # files, see https://www.devco.net/archives/2016/02/03/puppet-4-data-lookup-strategies.php
    $opts = hiera_hash('mesos::slave::options', $options)
    $merged_options = merge($systemd_support, $opts, $isolator_options, $credentials_options)
  } else {
    $merged_options = merge($systemd_support, $options, $isolator_options, $credentials_options)
  }

  # work_dir can't be specified via options,
  # we would get a duplicate declaration error
  mesos::property {'slave_work_dir':
    value  => $work_dir,
    dir    => $conf_dir,
    file   => 'work_dir',
    owner  => $owner,
    group  => $group,
    notify => Service['mesos-slave'],
  }

  file { $work_dir:
    ensure => directory,
  }

  file { $credentials_file:
    ensure  => $credentials_ensure,
    content => $credentials_content,
    mode    => '0400',
    notify  => Service['mesos-slave'],
  }

  create_resources(mesos::property,
    mesos_hash_parser($merged_options, 'slave'),
    {
      dir    => $conf_dir,
      owner  => $owner,
      group  => $group,
      notify => Service['mesos-slave'],
    }
  )

  create_resources(mesos::property,
    mesos_hash_parser($resources, 'resources'),
    {
      dir    => "${conf_dir}/resources",
      owner  => $owner,
      group  => $group,
      notify => Service['mesos-slave'],
    }
  )

  create_resources(mesos::property,
    mesos_hash_parser($attributes, 'attributes'),
    {
      dir    => "${conf_dir}/attributes",
      owner  => $owner,
      group  => $group,
      notify => Service['mesos-slave'],
    }
  )

  file { $conf_file:
    ensure  => 'present',
    content => template('mesos/slave.erb'),
    mode    => '0644',
    require => [Class['mesos::config'], File[$conf_dir], Package['mesos']],
  }

  $logger_ensure = $syslog_logger ? {
    true  => absent,
    false => present,
  }
  mesos::property { 'slave_logger':
    ensure  => $logger_ensure,
    file    => 'logger',
    value   => false,
    dir     => $conf_dir,
    owner   => $owner,
    group   => $group,
    require => File[$conf_dir],
  }

  # Install mesos-slave service
  mesos::service { 'slave':
    enable              => $enable,
    service_provider    => $service_provider,
    manage              => $manage_service,
    subscribe           => File[$conf_file],
    manage_service_file => $manage_service_file,
    systemd_wants       => $systemd_wants,
    systemd_after       => $systemd_after,
  }

  if (!defined(Class['mesos::master']) and $single_role) {
    mesos::service { 'master':
      enable => false,
      manage => $manage_service,
    }
  }
}
