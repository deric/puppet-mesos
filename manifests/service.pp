# Define: mesos::service
#
# This module manages mesos services
#
# Parameters:
#  [*enable*] - enable service autostart
#
# Should not be called directly
#
define mesos::service(
  $enable = false,
) {

  service { "mesos-${name}":
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => $enable,
    subscribe  => [ File['/etc/default/mesos'],
      File["/etc/default/mesos-${name}"]
    ],
  }
}
