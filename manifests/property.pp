# Used for storing configuration in
# directory structure

define mesos::property (
  $value,
  $dir,
  $service, #service to be notified about property changes
  $file = $title,
) {

  if is_bool($value) {
    $filename = $value ? {
      true => "${dir}/?${file}",
      false => "${dir}/?no-${file}",
    }
    $ensure = 'present'
    $content = ''
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
    require => File[$dir],
    notify  => $service,
  }

}
