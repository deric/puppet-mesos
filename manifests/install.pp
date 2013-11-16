# Class: mesos::install
#
# This module manages Mesos installation
#
# Parameters: None
#
# Actions: None
#
# Requires:
#
# Sample Usage: include mesos::install
#
class mesos::install(
  $ensure = $mesos::ensure,
) {

  # 'ensure_packages' requires puppetlabs/stdlib
  #
  # linux containers are now implemented natively
  # with usage of cgroups, requires kernel >= 2.6.24
  ensure_packages(['python'])

  # a debian (or other binary package) must be available, see https://github.com/deric/mesos-deb-packaging
  # for Debian packaging
  package { 'mesos':
    ensure  => $ensure,
    require => Package['python']
  }
}
