# Mesos Puppet Module
[![Build Status](https://travis-ci.org/deric/puppet-mesos.png)](https://travis-ci.org/deric/puppet-mesos)

This is a Puppet module for managing Mesos nodes in a cluster.

## Requirements

  * Puppet 3 (or 2.6 with hiera gem)
  * Mesos binary package, for Debian see [mesos deb packaging](https://github.com/deric/mesos-deb-packaging)

## Usage

  Should be as simple as this, on master node:

```puppet
class{'mesos::master': }
```

  For slave you have to specify either `master` or `zookeeper` node(s) to connect.

```puppet
class{'mesos::slave':
  master => '192.168.1.1'
}
```

### Slave

 - `enable` - install Mesos slave service (default: `true`)
 - `start`  - autostart of Mesos slave service (default: `true`)
 - `master`- ip address of Mesos master (default: `localhost`)
 - `master_port` - Mesos master's port (default: `5050`)
 - `zookeeper` - Zookeeper URL string (which keeps track
             of current Mesos master)
 - `work_dir` - directory for storing task's temporary files (default: `/tmp/mesos`)

## Hiera support

  All configuration could be handled by hiera.

  Either specify one master

    mesos::master      : '192.168.1.1'

  or [Zookeeper](http://zookeeper.apache.org/) could be use for a fault-tolerant setup (multiple instances of zookeeper are separated by comma):

    mesos::zookeeper   : 'zk://192.168.1.1:2181/mesos'
    mesos::master_port : 5050
    mesos::log_dir     : '/var/log/mesos'
    mesos::conf_dir    : '/etc/mesos'
    mesos::cluster     : 'my_mesos_cluster'
    mesos::whitelist   : '*'


## Links

For more information see [Mesos project](http://mesos.apache.org/)

## License

Apache License 2.0

