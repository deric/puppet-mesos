# Class: mesos::slave
#
# This module manages mesos slave
#
# Parameters: None
#
# Actions: None
#
# Requires: mesos::install
#
# Sample Usage: include mesos::slave
#
class mesos::slave {
  require mesos::install
  include mesos::config
  include mesos::params

  # Install  /etc/default/mesos-slave
  mesos::service { 'slave':
    start      => 'yes',
    enable     => true,
    ensure     => "running",
  }

}

