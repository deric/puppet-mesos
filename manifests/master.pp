# Class: mesos::master
#
# This module manages mesos master
#
# Parameters: None
#
# Actions: None
#
# Requires: mesos::install
#
# Sample Usage: include mesos::master
#
class mesos::master {
  require mesos::install
  include mesos::config
  include mesos::params

  # Install  /etc/default/mesos-master
  mesos::service { 'master':
    start      => 'yes',
    enable     => true,
  }

}

