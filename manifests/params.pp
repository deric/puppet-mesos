class mesos::params {
  $_defaults = {
    'packages' => ['mesos'],
    'service_provider' => undef,
  }

  case $facts['os']['family'] {
    'Debian': {
      case $facts['os']['name'] {
        'Debian': {
          case $facts['os']['release']['major'] {
            '7': { $initstyle = 'init' }
            '8': { $initstyle = 'systemd' }
            default: { $initstyle = undef }
          }
        }
        'Ubuntu': {
          case $facts['os']['release']['major'] {
            '12.04': { $initstyle = 'upstart' }
            '14.04': { $initstyle = 'upstart' }
            '16.04': { $initstyle = 'systemd' }
            default: { $initstyle = undef }
          }
        }
        default: { $initstyle = undef }
      }

      $_os_overrides = {
        'service_provider' => $initstyle,
      }
    }
    'Redhat': {
      case $facts['os']['release']['major'] {
        #'6': { $initstyle = 'redhat' } # TODO: mesosphere packages works with upstart
        '6': { $initstyle = 'upstart' } # see issue #28
        '7': { $initstyle = 'systemd' }
        default: { $initstyle = undef }
      }
      $_os_overrides = {
        'service_provider' => $initstyle,
      }
    }

    default: {
      $_os_overrides = {}
    }
  }
  $_params = merge($_defaults, $_os_overrides)


  $packages = $_params['packages']
  $service_provider = $_params['service_provider']

  $config_file_owner   = 'root'
  $config_file_group   = 'root'
  $config_file_mode    = '0644'
  $manage_service_file = false
  $systemd_after       = 'network.target'
  $systemd_wants       = 'network.target'
  $systemd_path        = '/etc/systemd/system'
}
