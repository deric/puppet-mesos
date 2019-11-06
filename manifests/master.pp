# Class: mesos::master
#
# This module manages Mesos master - installs Mesos package
# and starts master service.
#
# Sample Usage:
#
# class{ 'mesos::master': }
#
# Parameters:
#
#  [*single_role*]
#    Currently Mesos packages ships with both mesos-master and mesos-slave
#    enabled by default. `single_role` assumes that you use only either of
#    those on one machine. Default: true (mesos-slave service will be
#    disabled on master node)
#  [*manage_service_file*]
#    Whether override default service files (currently supported only for systemd)
#    default: false
#
#
# mesos-master service stores configuration in /etc/default/mesos-master in file/directory
# structure. Arguments passed via $options hash are converted to file/directories
#
class mesos::master(
  Boolean                                 $enable              = true,
  String                                  $cluster             = 'mesos',
  Stdlib::Absolutepath                    $conf_dir            = '/etc/mesos-master',
  Stdlib::Absolutepath                    $work_dir            = '/var/lib/mesos', # registrar directory, since 0.19
  Stdlib::Absolutepath                    $conf_file           = '/etc/default/mesos-master',
  Stdlib::Absolutepath                    $acls_file           = '/etc/mesos/acls',
  Stdlib::Absolutepath                    $credentials_file    = '/etc/mesos/master-credentials',
  Integer                                 $master_port         = $mesos::master_port,
  Optional[Variant[String,Array[String]]] $zookeeper           = $mesos::zookeeper,
  String                                  $zk_path             = $mesos::zk_path,
  Integer                                 $zk_default_port     = $mesos::zk_default_port,
  String                                  $owner               = $mesos::owner,
  String                                  $group               = $mesos::group,
  Optional[String]                        $listen_address      = $mesos::listen_address,
  Boolean                                 $manage_service      = $mesos::manage_service,
  Hash                                    $env_var             = {},
  Hash                                    $options             = {},
  Hash                                    $acls                = {},
  Array                                   $credentials         = [],
  Boolean                                 $syslog_logger       = true,
  Boolean                                 $use_hiera           = $mesos::use_hiera,
  Boolean                                 $single_role         = $mesos::single_role,
  Optional[String]                        $service_provider    = $mesos::service_provider,
  Boolean                                 $manage_service_file = $::mesos::manage_service_file,
  String                                  $systemd_wants       = $::mesos::params::systemd_wants,
  String                                  $systemd_after       = $::mesos::params::systemd_after,
) inherits ::mesos {

  if (!empty($acls)) {
    $acls_options = {'acls' => $acls_file}
    $acls_content = inline_template("<%= require 'json'; @acls.to_json %>")
    $acls_ensure = file
  } else {
    $acls_options = {}
    $acls_content = undef
    $acls_ensure = absent
  }

  if (!empty($credentials)) {
    $credentials_options = {'credentials' => "file://${credentials_file}"}
    $credentials_content = inline_template("<%= require 'json'; {:credentials => @credentials}.to_json %>")
    $credentials_ensure = file
  } else {
    $credentials_options = {}
    $credentials_content = undef
    $credentials_ensure = absent
  }

  if $use_hiera {
    # In Puppet 3 automatic lookup won't merge options across multiple config
    # files, see https://www.devco.net/archives/2016/02/03/puppet-4-data-lookup-strategies.php
    $opts = hiera_hash('mesos::master::options', $options)
    $merged_options = merge($opts, $acls_options, $credentials_options)
  } else {
    $merged_options = merge($options, $acls_options, $credentials_options)
  }

  if !empty($zookeeper) {
    if is_string($zookeeper) {
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
    notify  => Service['mesos-master'], # when key is removed we want to reload the service
  }

  file { $work_dir:
    ensure => directory,
  }

  file { $acls_file:
    ensure  => $acls_ensure,
    content => $acls_content,
    mode    => '0444',
    notify  => Service['mesos-master'],
  }

  file { $credentials_file:
    ensure  => $credentials_ensure,
    content => $credentials_content,
    mode    => '0400',
    notify  => Service['mesos-master'],
  }

  # work_dir can't be specified via options,
  # we would get a duplicate declaration error
  mesos::property {'master_work_dir':
    value  => $work_dir,
    dir    => $conf_dir,
    file   => 'work_dir',
    owner  => $owner,
    group  => $group,
    notify => Service['mesos-master'],
  }

  create_resources(mesos::property,
    mesos_hash_parser($merged_options, 'master'),
    {
      dir    => $conf_dir,
      owner  => $owner,
      group  => $group,
      notify => Service['mesos-master'],
    }
  )

  file { $conf_file:
    ensure  => present,
    content => template('mesos/master.erb'),
    mode    => '0644',
    require => [File[$conf_dir], Package['mesos']],
  }

  # When launched by the "mesos-init-wrapper", the Mesos service's stdout/stderr
  # are logged to syslog using logger (http://linux.die.net/man/1/logger). This
  # is disabled using the "--no-logger" flag. There is no equivalent "--logger"
  # flag so the option must either be present or completely removed.
  $logger_ensure = $syslog_logger ? {
    true  => absent,
    false => present,
  }
  mesos::property { 'master_logger':
    ensure => $logger_ensure,
    file   => 'logger',
    value  => false,
    dir    => $conf_dir,
    owner  => $owner,
    group  => $group,
  }

  # Install mesos-master service
  mesos::service { 'master':
    enable              => $enable,
    service_provider    => $service_provider,
    manage              => $manage_service,
    subscribe           => File[$conf_file],
    manage_service_file => $manage_service_file,
    systemd_wants       => $systemd_wants,
    systemd_after       => $systemd_after,
  }

  if (!defined(Class['mesos::slave']) and $single_role) {
    mesos::service { 'slave':
      enable => false,
      manage => $manage_service,
    }
  }
}
