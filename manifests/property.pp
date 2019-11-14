# == Define: mesos::property
#
# This definition can set one of the option files in the mesos configuration
# directories. These files will be used as command line options by the
# mesos services.
#
# === Examples
#
# mesos::property { 'my_option' :
#   value => 'my_value',
#   dir   => '/etc/my_service/conf,
# }
#
# === Parameters
#
# [*value*]
# (required) The value of this option. If this parameter is boolean, the
# predicate option file will be created.
#
# [*file*]
# If this parameter is set, this value will be used instead of the definition
# title as the option name.
#
# [*dir*]
# (required) The root directory of this options. Should be set to the service
# configuration directory.
#
# [*ensure*]
# Create or remove the option. Can be one of present, absent, file.
# Default: present
#
# [*owner*]
# Which system yser should own this file?
# Default: root
#
# [*group*]
# What system groups should this file belong?
# Default: root
#
# [*mode*]
# What access mode should this file have?
# Default: 0644
#
define mesos::property (
  Stdlib::Absolutepath $dir,
  $value,
  Enum['present', 'absent', 'file'] $ensure  = 'present',
  Optional[String] $file    = undef,
  Optional[String] $service = undef,
  Optional[String] $owner   = undef,
  Optional[String] $group   = undef,
  Optional[String] $mode    = undef,
) {
  include ::mesos::params

  if $service {
    fail("\$service is deprecated and will be removed in the next major release, please use \$notify => ${service} instead")
  }

  $file_name  = pick($file, $name)
  $file_owner = pick($owner, $mesos::params::config_file_owner)
  $file_group = pick($group, $mesos::params::config_file_group)
  $file_mode  = pick($mode,  $mesos::params::config_file_mode)

  if $value =~ Boolean {
    if $value {
      $file_path = "${dir}/?${file_name}"
    } else {
      $file_path = "${dir}/?no-${file_name}"
    }
    $file_content = ''
    $file_ensure = $ensure
  } elsif $value =~ Numeric {
    # function empty() from puppetlabs-stdlib prior to 4.10.0 does not handle numeric values
    # thus we need to treat numeric values differently
    # TODO: this block can be safely removed after upgrading stdlib
    $file_path = "${dir}/${file_name}"
    if $ensure == undef {
      $file_ensure = present
    } else {
      $file_ensure = $ensure
    }
    $file_content = "${value}\n"
  } else {
    $file_path = "${dir}/${file_name}"
    if empty($value) {
      # TODO: remove in 0.9
      warning("Setting \$value to an empty value is deprecated and will be removed \
        in the next major release, please use \$ensure => absent instead")
      if $ensure == 'file' {
        $file_ensure = 'present'
      } else {
        $file_ensure = 'absent'
      }
    } else {
      $file_ensure = $ensure
    }
    $file_content = "${value}\n"
  }

  file { $file_path :
    ensure  => $file_ensure,
    content => $file_content,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    notify  => $service,
  }

}
