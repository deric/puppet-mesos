# Used for storing configuration in
# directory structure

define mesos::property (
  $value,
  $dir,
  $service, #service to be notified about property changes
  $file = $title,
) {

  file { "${dir}/${file}":
    ensure  => empty($value) ? {
      true  => absent,
      false => present,
    },
    content => $value,
    require => File[$dir],
    notify  => $service,
  }

}
