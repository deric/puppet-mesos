# Mesos Puppet Module

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
class{'mesos::slave': }
```

  Configuration should be handled by hiera.

  Either specify one master

    mesos_master      : '192.168.1.1'

  or [zookeeper](http://zookeeper.apache.org/) could be use for a fault-tolerant setup (multiple instances of zookeeper are separated by comma):

    mesos_zk          : 'zk://192.168.1.1:2181/mesos'
    mesos_master_port : 5050
    mesos_log_dir     : '/var/log/mesos'
    mesos_conf_dir    : '/etc/mesos'
    mesos_cluster     : 'my_mesos_cluster'
    mesos_slaves      : '*'
    mesos_whitelist   : '*'


## Links

For more information see [Mesos project](http://mesos.apache.org/)

## License

Apache License 2.0

