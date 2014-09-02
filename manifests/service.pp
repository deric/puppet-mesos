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
  $enable         = false,
  $force_provider = undef,
) {

  service { "mesos-${name}":
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => $enable,
    provider   => $force_provider,
    subscribe  => [ File['/etc/default/mesos'],
      File["/etc/default/mesos-${name}"]
    ],
  }
}
