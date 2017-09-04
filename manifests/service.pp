# Define: mesos::service
#
# This module manages mesos services
#
# Parameters:
#  [*enable*] - enable service autostart
#  [*manage*] - whether puppet should ensure running/stopping services
#  [*force_provider*] - choose a service provider; default = undef = system default; 'none' does not create a service resource at all.
#
# Should not be called directly
#
define mesos::service(
  $enable              = false,
  $force_provider      = undef,
  $manage              = true,
  $manage_service_file = $::mesos::manage_service_file,
  $systemd_after       = $::mesos::params::systemd_after,
  $systemd_wants       = $::mesos::params::systemd_wants,
) {

  include ::mesos

  if $manage {
    if $enable {
      $ensure_service = 'running'
    } else {
      $ensure_service = 'stopped'
    }
  } else {
    $ensure_service = undef
  }

  if $manage_service_file == true {
    if $force_provider == 'systemd'  {
      file { "${::mesos::systemd_path}/mesos-${name}.service":
        ensure  => 'present',
        content => template("${module_name}/systemd.${name}-service.erb"),
      }
      ~> exec { "systemctl daemon-reload # for mesos-${name} service":
        refreshonly => true,
        path        => $::path,
        notify      => Service["mesos-${name}"]
      }
    }
  }

  if ($force_provider != 'none') {
    service { "mesos-${name}":
      ensure     => $ensure_service,
      hasstatus  => true,
      hasrestart => true,
      enable     => $enable,
      provider   => $force_provider,
      subscribe  => [
        File[$mesos::conf_file],
        Package['mesos']
      ],
    }
  }
}
