# Define: mesos::service
#
# This module manages mesos services
#
# Parameters:
#  [*enable*] - enable service autostart
#  [*force_provider*] - choose a service provider; default = undef = system default; 'none' does not create a service resource at all.
#
# Should not be called directly
#
define mesos::service(
  $enable         = false,
  $force_provider = undef,
) {

  if ($force_provider != 'none') {
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
}
