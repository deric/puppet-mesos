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

  if is_bool($value) {
    $filename = $value ? {
      true => "${dir}/?${file}",
      false => "${dir}/?no-${file}",
    }
    $real_ensure = $ensure ? {
      undef   => 'present',
      default => $ensure,
    }
    $content = ''
  } elsif is_numeric($value) {
    $filename = "${dir}/${file}"
    $real_ensure = $ensure ? {
      undef   => 'present',
      default => $ensure,
    }
    $content = "${value}"
  } else {
    $filename = "${dir}/${file}"
    if $ensure == undef {
      $real_ensure = empty($value) ? {
        true  => absent,
        false => present,
      }
    } else {
      $real_ensure = $ensure
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
