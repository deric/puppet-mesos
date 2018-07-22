# Define: mesos::service
#
# This module manages mesos services
#
# Parameters:
#  [*enable*] - enable service autostart
#  [*manage*] - whether puppet should ensure running/stopping services
#  [*service_provider*] - choose a service provider; default = undef = system default; 'none' does not create a service resource at all.
#
# Should not be called directly
#
define mesos::service(
  Boolean          $enable              = false,
  Optional[String] $service_provider    = undef,
  Boolean          $manage              = true,
  Boolean          $manage_service_file = $::mesos::manage_service_file,
  String           $systemd_after       = $::mesos::params::systemd_after,
  String           $systemd_wants       = $::mesos::params::systemd_wants,
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
    if $service_provider == 'systemd'  {
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

  if ($service_provider != 'none') {
    service { "mesos-${name}":
      ensure     => $ensure_service,
      hasstatus  => true,
      hasrestart => true,
      enable     => $enable,
      provider   => $service_provider,
      subscribe  => [
        File[$mesos::conf_file],
        Package['mesos']
      ],
    }
  }
}
