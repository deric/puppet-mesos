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
class mesos::master(
  $enable = true,
  $star   = 'yes',
) inherits mesos {

  require mesos::install

  # Install  /etc/default/mesos-master
  mesos::service { 'master':
    start      => $start,
    enable     => $enable,
  }

}

