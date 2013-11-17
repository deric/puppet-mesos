# Define: mesos::service
#
# This module manages mesos services
#
# Parameters:
#  [*start*] - start service by during boot-time
#  [*enable*] - enable service
#  [*conf_dir*] - path to service configuration files
#
# Sample Usage:
#   mesos::service { 'master':
#     start      => 'yes',
#   }
#
define mesos::service(
  $start = 'no',
  $enable = false,
  $conf_dir = '/etc/mesos',
) {

  if $start == 'yes' {
    service { "mesos-${name}":
      ensure    => 'running',
      hasstatus => true,
      hasrestart => true,
      enable    => $enable,
      subscribe => [ File['/etc/default/mesos'],
        File["${conf_dir}/${name}.conf"]
      ],
    }
  }
}
