# == Class mesos::repo
#
# This class manages apt/yum repository for Mesos packages
#
# [source] - either a string (e.g.: 'mesoshpere') or a hash containing
#   repository configuration (currently only for Debian)
#

class mesos::repo(
  $source = undef
) {

  if $source {
    case $facts['os']['family'] {
      'Debian': {
        include ::apt

        $os = downcase($facts['os']['family'])
        $mesosphere_apt = {
          location => "http://repos.mesosphere.io/${os}",
          release  =>  $facts['os']['distro']['codename'],
          repos    => 'main',
          key      => {
            'id'     => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
            'server' => 'keyserver.ubuntu.com',
          },
          include  => {
            'src' => false
          },
        }

        # custom configuration
        if is_hash($source) {
          # merge configuration with mesosphere's defaults
          $repo_config = deep_merge($mesosphere_apt, $source)
          ensure_resource('apt::source', 'mesos-custom', $repo_config)
          anchor { 'mesos::repo::begin': }
            -> Apt::Source['mesos-custom']
            -> Class['apt::update']
            -> anchor { 'mesos::repo::end': }
        } else {
          case $source {
            undef: {} #nothing to do
            'mesosphere': {
              ensure_resource('apt::source', 'mesosphere', $mesosphere_apt)
              anchor { 'mesos::repo::begin': }
                -> Apt::Source['mesosphere']
                -> Class['apt::update']
                -> anchor { 'mesos::repo::end': }
            }
            default: {
              notify { "APT repository '${source}' is not supported for ${facts['os']['family']}": }
            }
          } # case $source
        }
      } # case Debian
      'RedHat': {
        case $source {
          undef: {} #nothing to do
          'mesosphere': {
            $osrel = $facts['os']['release']['major']
            $mrel = $facts['os']['release']['minor']
            case $osrel {
              '6', '7': {
                exec { 'yum-clean-expire-cache':
                  user        => 'root',
                  path        => '/usr/bin',
                  refreshonly => true,
                  command     => 'yum clean expire-cache',
                }
                -> package { 'mesosphere-el-repo':
                  ensure   => present,
                  provider => 'rpm',
                  source   => "http://repos.mesosphere.io/el/${osrel}/noarch/RPMS/mesosphere-el-repo-${osrel}-${mrel}.noarch.rpm"
                }
              }
              default: {
                notify { "Yum repository '${source}' is not supported for major version ${osrel}": }
              }
            }
          }
          default: {
            notify { "Repository \"${source}\" is not supported yet.": }
          }
        }
      }
      default: {
        fail("\"${module_name}\" provides no repository information for OSfamily \"${facts['os']['family']}\"")
      }
    }
  }
}
