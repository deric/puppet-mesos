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
  $cluster      = params_lookup('cluster', '')
  $master_port  = params_lookup('master_port', '5050')
  
  $slaves       = params_lookup('slaves', '*')
  $whitelist    = params_lookup('whitelist', '*')
  
  
  # master and slave creates separate logs automatically
  # TODO: currently not used
  $log_dir      = params_lookup('log_dir', '/var/log/mesos')
  $conf_dir     = params_lookup('conf_dir', '/etc/mesos')
  
  # slave
  $zk           = params_lookup('zk', '') # e.g. zk://localhost:2181/mesos
  # if "zk" is empty, master value is used
  $master       = params_lookup('master', '127.0.0.1')
  $slave_port   = params_lookup('slave_port', '5051')
  $work_dir     = params_lookup('work_dir', '/tmp/mesos')
  $checkpoint   = params_lookup('checkpoint', false)
}
