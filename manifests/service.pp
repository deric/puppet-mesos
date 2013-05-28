# Define: mesos::service
#
# This module manages mesos serviceation
#
# Parameters: None
#
# Actions: None
#
# Requires: mesos::install
#
# Sample Usage: mesos::service { 'master':
#                 start      => 'yes',
#               }
#
define mesos::service( $start = 'no', $enable = false) {

  file { "/etc/default/mesos-${name}":
    require => Package['mesos'],
    content => template('mesos/service.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }
  
  if $start == 'yes' {
    service { "mesos-${name}":      
      hasstatus => true,
      enable    => $enable,
      subscribe => [File["/etc/mesos/mesos.conf"], File["/etc/default/mesos"], File["/etc/default/mesos-${name}"]],
    }
  }


}
