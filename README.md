# Mesos Puppet Module
[![Build Status](https://travis-ci.org/deric/puppet-mesos.png)](https://travis-ci.org/deric/puppet-mesos)

This is a puppet module for managing mesos nodes in a cluster.

## Requirements

  * Puppet 3 (or 2.6 with hiera gem)
  * Mesos binary package, for Debian see [mesos deb packaging](https://github.com/deric/mesos-deb-packaging)

## Usage

  Should be as simple as this, on master node:

```puppet
class{'mesos::master': }
```

  On slave:

```puppet
class{'mesos::slave':
  master => '192.168.1.1'
}
```

## Hiera support

  Configuration could be handled by hiera.

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

