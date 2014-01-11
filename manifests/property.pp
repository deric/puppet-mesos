# Used for storing configuration in
# directory structure

define mesos::property (
  $value,
  $dir,
  $file = $title,
) {

  file { "${dir}/${file}":
    ensure  => present,
    content => $value,
    require => File[$dir],
  }
}