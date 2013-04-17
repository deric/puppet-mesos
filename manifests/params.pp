# Class: mesos::params
#
# This module manages mesos::params
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class storm::params {
   
  $mesos_master = hiera('master', '127.0.0.1')

}
