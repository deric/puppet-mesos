# Used for storing configuration in
# directory structure

define mesos::property (
  $value,
  $dir,
  $service, #service to be notified about property changes
  $file = $title,
  $owner = 'root',
  $group = 'root',
) {

  if is_bool($value) {
    $filename = $value ? {
      true => "${dir}/?${file}",
      false => "${dir}/?no-${file}",
    }
    $ensure = 'present'
    $content = ''
  } elsif is_numeric($value) {
    $filename = "${dir}/${file}"
    $ensure = 'present'
    $content = "${value}"
  } else {
    $filename = "${dir}/${file}"
    $ensure = empty($value) ? {
      true  => absent,
      false => present,
    }
    $content = $value
  }

  file { $filename:
    ensure  => $ensure,
    content => $content,
    owner   => $owner,
    group   => $group,
    require => File[$dir],
    notify  => $service,
  }

}
