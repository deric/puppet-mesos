# == Class mesos::repo
#
# This class manages apt repository for Mesos packages
#

class mesos::repo(
  $source = undef
) {

  if $source {
    case $::osfamily {
      'Debian': {
        if !defined(Class['apt']) {
          class { 'apt': }
        }

        $distro = downcase($::operatingsystem)

        case $source {
          undef: {} #nothing to do
          'mesosphere': {
            apt::source { 'mesosphere':
              location    => "http://repos.mesosphere.io/${distro}",
              release     => $::lsbdistcodename,
              repos       => 'main',
              key         => 'E56151BF',
              key_server  => 'keyserver.ubuntu.com',
              include_src => false,
            }
          }
          default: {
            notify { "APT repository '${source}' is not supported for ${::osfamily}": }
          }
        }
      }
      'redhat': {
        case $source {
        undef: {} #nothing to do
        'mesosphere': {
          case $::operatingsystemmajrelease {
            '6': {
              package { 'mesosphere-el-repo':
                ensure => present,
                source => 'http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm'
              }
            }
            '7': {
              package { 'mesosphere-el-repo':
                ensure => present,
                source => 'http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm'
              }
            }
            default: {
              notify { "Yum repository '${source}' is not supported for major version ${::operatingsystemmajrelease}": }
            }
          }
        }
      }
      default: {
        fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
      }
    }
  }
}
