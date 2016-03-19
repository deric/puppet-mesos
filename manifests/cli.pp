# == Class mesos::cli
#
# Manages optional CLI packages providing e.g. command: `mesos ps`.
#
# Python 2.7 is required
# === Parameters
#
#  [*zookeeper*]
#     A zookeeper URL in format 'zk://server1:port[,server2:port]/mesos'
#
class mesos::cli(
  $ensure           = 'present',
  $packages         = ['mesos.cli', 'mesos.interface'],
  $pip_package      = 'python-pip',
  $manage_pip       = true,
  $package_provider = undef,
  $response_timeout = 5,
  $log_file         = 'null',
  $log_level        = 'warning',
  $max_workers      = 5,
  $debug            = false,
  $scheme           = 'http',
  $owner            = $mesos::owner,
  $group            = $mesos::group,
  $master           = $mesos::master,
  $zookeeper        = $mesos::zookeeper_url,
) inherits mesos {
  validate_array($packages)

  if $manage_pip {
    ensure_packages($pip_package)
    Package[$pip_package] -> Package[$packages]
  }

  if $package_provider {
    $package_provider_real = $package_provider
  } else {
    if $manage_pip {
      $package_provider_real = 'pip'
    }
  }

  $defaults = {
    'provider' => $package_provider_real,
    'ensure'   => $ensure,
  }

  ensure_packages($packages, $defaults)

  file { '/etc/.mesos.json':
    ensure  => 'present',
    content => template('mesos/mesos.json.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
  }

}
