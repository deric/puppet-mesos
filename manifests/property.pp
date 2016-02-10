# Used for storing configuration in
# directory structure

define mesos::property (
  $value,
  $dir,
  $ensure = undef,
  $service = undef, #service to be notified about property changes
  $file = $title,
  $owner = 'root',
  $group = 'root',
) {
  if $service != undef {
    warning("\$service is deprecated and will be removed in the next major release, please use \$notify => ${service} instead")
  }

  case $ensure {
    present, file, absent: {
      $real_ensure = $ensure
    }
    undef: { }
    default: {
      fail("\$ensure must be one of 'present', 'file', 'absent', or undef, not '${ensure}'")
    }
  }

  if is_bool($value) {
    $filename = $value ? {
      true => "${dir}/?${file}",
      false => "${dir}/?no-${file}",
    }
    if $ensure == undef {
      $real_ensure = present
    }
    $content = ''
  } elsif is_numeric($value) {
    $filename = "${dir}/${file}"
    if $ensure == undef {
      $real_ensure = present
    }
    $content = "${value}"
  } else {
    $filename = "${dir}/${file}"
    if $ensure == undef {
      if empty($value) {
        warning("Setting \$value to an empty value is deprecated and will be removed in the next major release, please use \$ensure => absent instead")
        $real_ensure = absent
      } else {
        $real_ensure = present
      }
    }
    $content = $value
  }

  file { $filename:
    ensure  => $real_ensure,
    content => $content,
    owner   => $owner,
    group   => $group,
    notify  => $service,
  }

}
