class mesos::params {
  $_defaults = {
    'packages' => ['mesos'],
    'service_provider' => undef,
  }

  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          case $::operatingsystemmajrelease {
            '7': { $initstyle = 'init' }
            '8': { $initstyle = 'systemd' }
            default: { $initstyle = undef }
          }
        }
        'Ubuntu': {
          case $::operatingsystemmajrelease {
            'precise': { $initstyle = 'upstart' }
            'trusty': { $initstyle = 'upstart' }
            'xenial': { $initstyle = 'systemd' }
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
      case $::operatingsystemmajrelease {
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
