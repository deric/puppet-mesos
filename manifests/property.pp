# Used for storing configuration in
# directory structure

define mesos::property (
  $value,
  $dir,
  $file = $title,
) {

  file { "${dir}/${file}":
    ensure  => empty($value) ? {
      true  => absent,
      false => present,
    },
    content => $value,
    require => File[$dir]
  }
  
}
