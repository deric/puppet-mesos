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
  String                      $ensure           = 'present',
  Array[String]               $packages         = ['mesos.cli', 'mesos.interface'],
  String                      $pip_package      = 'python-pip',
  Boolean                     $manage_pip       = true,
  Optional[String]            $package_provider = undef,
  Integer                     $response_timeout = 5,
  Optional[String]            $log_file         = undef,
  String                      $log_level        = 'warning',
  Integer                     $max_workers      = 5,
  Boolean                     $debug            = false,
  String                      $scheme           = 'http',
  String                      $owner            = $mesos::owner,
  String                      $group            = $mesos::group,
  String                      $master           = $mesos::master,
  Optional[String]            $zookeeper        = $mesos::zookeeper_url,
) inherits mesos {

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
