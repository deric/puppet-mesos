# Class: mesos::master
#
# This module manages Mesos master - installs Mesos package
# and starts master service.
#
# Sample Usage:
#
# class{ 'mesos::master': }
#
# mesos-master service stores configuration in /etc/default/mesos-master in file/directory
# structure. Arguments passed via $options hash are converted to file/directories
#
class mesos::master(
  $enable           = true,
  $cluster          = 'mesos',
  $conf_dir         = '/etc/mesos-master',
  $work_dir         = '/var/lib/mesos', # registrar directory, since 0.19
  $conf_file        = '/etc/default/mesos-master',
  $acls_file        = '/etc/mesos/acls',
  $credentials_file = '/etc/mesos/master-credentials',
  $master_port      = $mesos::master_port,
  $zookeeper        = $mesos::zookeeper,
  $owner            = $mesos::owner,
  $group            = $mesos::group,
  $listen_address   = $mesos::listen_address,
  $manage_service   = $mesos::manage_service,
  $env_var          = {},
  $options          = {},
  $acls             = {},
  $credentials      = [],
  $force_provider   = undef, #temporary workaround for starting services
) inherits mesos {

  validate_hash($env_var)
  validate_hash($options)
  validate_hash($acls)
  validate_absolute_path($acls_file)
  validate_array($credentials)
  validate_absolute_path($credentials_file)
  validate_bool($manage_service)

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
    $credentials_options = {'credentials' => $credentials_file}
    $credentials_content = inline_template("<%= require 'json'; {:credentials => @credentials}.to_json %>")
    $credentials_ensure = file
  } else {
    $credentials_options = {}
    $credentials_content = undef
    $credentials_ensure = absent
  }

  $merged_options = merge($options, $acls_options, $credentials_options)

  file { $conf_dir:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    recurse => true,
    purge   => true,
    force   => true,
    require => Class['::mesos::install'],
  }

  file { $work_dir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
  }

  file { $acls_file:
    ensure  => $acls_ensure,
    content => $acls_content,
    owner   => $owner,
    group   => $group,
    mode    => '0444',
  }

  file { $credentials_file:
    ensure  => $credentials_ensure,
    content => $credentials_content,
    owner   => $owner,
    group   => $group,
    mode    => '0400',
  }

  # work_dir can't be specified via options,
  # we would get a duplicate declaration error
  mesos::property {'master_work_dir':
    value   => $work_dir,
    dir     => $conf_dir,
    file    => 'work_dir',
    owner   => $owner,
    group   => $group,
    notify  => Service['mesos-master'],
    require => File[$conf_dir],
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
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => [File[$conf_dir], Package['mesos']],
  }

  # Install mesos-master service
  mesos::service { 'master':
    enable         => $enable,
    force_provider => $force_provider,
    manage         => $manage_service,
    require        => File[$conf_file],
  }
}
