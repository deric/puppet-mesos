# == Class mesos::repo
#
# This class manages apt/yum repository for Mesos packages
#

class mesos::repo(
  $source = undef
) {

  if $source {
    case $::osfamily {
      'Debian': {
        include apt

        $distro = downcase($::operatingsystem)

        case $source {
          undef: {} #nothing to do
          'mesosphere': {
            apt::source { 'mesosphere':
              location => "http://repos.mesosphere.io/${distro}",
              release  => $::lsbdistcodename,
              repos    => 'main',
              key      => {
                'id'     => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
                'server' => 'keyserver.ubuntu.com',
              },
              include  => {
                'src' => false
              },
            }
            anchor { 'mesos::repo::begin': } ->
              Apt::Source['mesosphere'] ->
              Class['apt::update'] ->
            anchor { 'mesos::repo::end': }
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
            $osrel = $::operatingsystemmajrelease
            case $osrel {
              '6': {
                $mrel = '2'
              }
              '7': {
                $mrel = '1'
              }
              default: {
                notify { "'${mrel}' is not supported for ${source}": }
              }
            }
            case $osrel {
              '6', '7': {
                package { 'mesosphere-el-repo':
                  ensure   => present,
                  provider => 'rpm',
                  source   => "http://repos.mesosphere.io/el/${osrel}/noarch/RPMS/mesosphere-el-repo-${osrel}-${mrel}.noarch.rpm"
                }
              }
              default: {
                notify { "Yum repository '${source}' is not supported for major version ${::operatingsystemmajrelease}": }
              }
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
