# == Class mesos::cli
#
# Manages optional CLI packages providing e.g. command: `mesos ps`.
#
# Python 2.7 is required
#
class mesos::cli(
  $ensure           = 'present',
  $packages         = ['mesos.cli', 'mesos.interface'],
  $pip_package      = 'python-pip',
  $response_timeout = 5,
  $log_file         = 'null',
  $log_level        = 'warning',
  $max_workers      = 5,
  $debug            = false,
  $scheme           = 'http',
  $owner            = $mesos::owner,
  $group            = $mesos::group,
  $master           = $mesos::master,
  $zookeeper        = $mesos::zookeeper,
) inherits mesos {
  ensure_packages([$pip_package])
  ensure_resource('package', $packages,
    {
      'provider' => 'pip',
      'ensure'   => $ensure,
      'require'  => Package[$pip_package],
    }
  )

  file { '/etc/.mesos.json':
    ensure  => 'present',
    content => template('mesos/mesos.json.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
  }

}