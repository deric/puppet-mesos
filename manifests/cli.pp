# == Class mesos::cli
#
# Manages optional CLI packages providing e.g. command: `mesos ps`.
#
# Python 2.7 is required
#
class mesos::cli(
  $ensure      = 'present',
  $packages    = ['mesos.cli', 'mesos.interface'],
  $pip_package = 'python-pip',
){
  ensure_packages([$pip_package]) ~>
  ensure_resource('package', $packages,
    {
      'provider' => 'pip',
      'ensure'   => $ensure
    }
  )
}