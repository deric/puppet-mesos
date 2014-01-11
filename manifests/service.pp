# Define: mesos::service
#
# This module manages mesos services
#
# Parameters:
#  [*start*] - start service by during boot-time
#  [*enable*] - enable service
#
# Sample Usage:
#   mesos::service { 'master':
#     start      => 'yes',
#   }
#
define mesos::service(
  $enable = false,
) {

  service { "mesos-${name}":
    ensure    => 'running',
    hasstatus => true,
    hasrestart => true,
    enable    => $enable,
    subscribe => [ File['/etc/default/mesos'],
      File["/etc/default/mesos-${name}"]
    ],
  }
}
