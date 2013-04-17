# Class: mesos::params
#
# This module manages mesos::params
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mesos::params {
  
  # human readable name for cluster
  $cluster      = hiera('cluster', '')
  $mesos_master = hiera('master', '127.0.0.1')
  $master_port  = hiera('master_port', 5050)
  
  # master and slave creates separate logs automatically
  $log_dir      = hiera('log_dir', '/var/log/mesos')
  $conf_dir     = hiera('conf_dir', '/etc/mesos/conf')
}
