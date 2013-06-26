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
class mesos::install {
  
  # linux containers are now implemented natively with usage of cgroups
  mesos::requires { "$name-requires-python": package => 'python' }

  # a debian (or other binary package) must be available, see https://github.com/deric/mesos-deb-packaging 
  # for Debian packaging
  package { ['mesos']:
    # for debugging issues with deb package
    # @TODO should be replaced by 'present' in future
    ensure => 'latest'
  }

  define mesos::requires ( $ensure='installed', $package ) {
   if defined( Package[$package] ) {
    debug("$package already installed")
   } else {
    package { $package: ensure => $ensure }
   }
 } 
}

