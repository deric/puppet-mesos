# Mesos Puppet Module
[![Puppet
Forge](http://img.shields.io/puppetforge/v/deric/mesos.svg)](https://forge.puppetlabs.com/deric/mesos) [![Build Status](https://travis-ci.org/deric/puppet-mesos.png)](https://travis-ci.org/deric/puppet-mesos)

For installing master

```puppet
class{'mesos::master':
  zookeeper  => 'zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos',
  work_dir => '/var/lib/mesos',
  options => {
    quorum   => 2
  }
}
```
slaves:

```puppet
class{'mesos::slave':
  zookeeper  => 'zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos',
  listen_address => $::ipaddress
}
```

for using Hiera and other options see below.


## Shared parameters

Parameters:

 - `zookeeper` - ZooKeeper URL which is used for slaves connecting to the master and also for leader election, e.g.:
	- single ZooKeeper: `zk://127.0.0.1:2181/mesos` (which isn't fault tolerant)
        - multiple ZooKeepers: `zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos` (usually 3 or 5 ZooKeepers should be enough)
        - ZooKeeper URL will be stored in `/etc/mesos/zk`
 - `conf_dir` - directory with simple configuration files containing master/slave parameters (name of the file is a key, contents its value)
        - this directory will be completely managed by Puppet
 - `env_var` - shared master/slave execution environment variables (see example under slave)
 - `version` - install specific version of Mesos
 - `manage_python` - Control whether mesos module should install python

### Master

  Should be as simple as this, on master node:

  ```puppet
class{'mesos::master': }
```
optionally you can specify some parameters or it is possible to configure Mesos via Hiera (see below).

```puppet
class{'mesos::master':
  master_port => 5050,
  work_dir => '/var/lib/mesos',
  options => {
    quorum   => 4
  }
}
```

  For slave you have to specify either `master`

```puppet
class{'mesos::slave':
  master => '192.168.1.1'
}
```
or `zookeeper` node(s) to connect:
```puppet
class{'mesos::slave':
  zookeeper => 'zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos'
}
```
 - `conf_dir` default value is `/etc/mesos-master` (this directory will be purged by Puppet!)
 	- for list of supported options see `mesos-master --help`
 - `env_var` - master's execution environment variables (see example under slave)

#### listen address

If you want to change the IP address Mesos is binding to, you can either provide a Puppet Fact:

```puppet
class{'mesos::master':
  listen_address => $::ipaddress_eth0
}
```
or directly use some IP address:

```puppet
class{'mesos::master':
  listen_address => '192.168.1.1'
}
```

By default no IP address is set, which means that Mesos will use IP to which translates `hostname -f` (you can influence bind address simply in `/etc/hosts`).


### Slave

 - `enable` - install Mesos slave service (default: `true`)
 - `port` - slave's port for incoming connections (default: `5051`)
 - `master`- ip address of Mesos master (default: `localhost`)
 - `master_port` - Mesos master's port (default: `5050`)
 - `work_dir` - directory for storing task's temporary files (default: `/tmp/mesos`)
 - `env_var` - slave's execution environment variables - a Hash, if you are using
 Java, you might need e.g.:

```puppet
class{'mesos::slave':
  master  => '192.168.1.1',
  env_var => {
    'JAVA_HOME' => '/usr/bin/java'
  }
}
```

in a similar manner you can specify cgroups isolation:

```puppet
class{'mesos::slave':
  zookeeper  => 'zk://192.168.1.1:2181/mesos',
  isolation  => 'cgroups/cpu,cgroups/mem',
  cgroups    => {
    'hierarchy' => '/sys/fs/cgroup',
    'root'      => 'mesos',
  }
}
```
 - `conf_dir` default value is `/etc/mesos-slave` (this directory will be purged by Puppet!)
        - for list of supported options see `mesos-slave --help`

## File based configuration

As Mesos configuration flags changes with each version we don't provide directly a named parameter for each flag. `mesos::property` allows to create a parameter file or remove the file when `value` is left empty. e.g. configure value in `/etc/mesos/hostname`:

```puppet
::mesos::property { 'hostname':
  value => 'mesos.hostname.com',
  dir   => '/etc/mesos'
}
```

Remove this file simply set value to undef:

```puppet
::mesos::property { 'hostname':
  value => undef,
  dir   => '/etc/mesos'
}
```

This is equivalent approach to

```puppet
class{'mesos::slave':
  options => {
    'hostname' => 'mesos.hostname.com'
  }
}
```
which will create a file `/etc/mesos-slave/hostname` with content `mesos.hostname.com` (where `/etc/mesos-slave` is a slave's `$conf_dir`).

Yet another option would be to pass this value via Hiera (see the section below).


### Boolean flags

Current Mesos packages recognizes boolean flags like `--[no-]quiet` via files named as `/etc/mesos-slave/?quiet` for `--quiet` (true) and `/etc/mesos-slave/?no-quiet` for false value.

```puppet
class{'mesos::slave':
  options => {
    'quiet' => true
  }
}
```

 *since 0.4.1*

## Hiera support

  All configuration could be handled by hiera.

  Either specify one master

```yaml
mesos::master      : '192.168.1.1'
```

  or [Zookeeper](http://zookeeper.apache.org/) could be use for a fault-tolerant setup (multiple instances of zookeeper are separated by comma):

```yaml
mesos::zookeeper   : 'zk://192.168.1.1:2181/mesos'
```

Some parameters are shared between master and slave nodes:

```yaml
mesos::master_port : 5050
mesos::log_dir     : '/var/log/mesos'
mesos::conf_dir    : '/etc/mesos'
mesos::owner       : 'mesos'
mesos::group       : 'mesos'
```

Other are master specific:

```yaml
mesos::master::cluster     : 'my_mesos_cluster'
mesos::master::whitelist   : '*'
```

or slave specific:

```yaml
mesos:slave::env_var:
  JAVA_HOME: '/usr/bin/java'
```

Mesos service reads configuration either from ENV variables or from configuration files wich are stored in `/etc/mesos-slave` resp. `/etc/mesos-master`. Hash passed via `options` will be converted to config files. Most of the options is possible to configure this way:

```yaml
mesos::master::options:
  webui_dir: '/usr/local/share/mesos/webui'
  quorum: '4'
```

you can also use facts from Puppet:

```
mesos::master::options:
  hostname: "%{::fqdn}"
```


cgroups with Hiera:

```yaml
mesos::slave::isolation: 'cgroups/cpu,cgroups/mem'
mesos::slave::cgroups:
  hierarchy: '/sys/fs/cgroup'
```

Limit resources used by Mesos slave:

```yaml
mesos::slave::resources:
  cpus: '10'
```

### Python installation

Python is required for Mesos Web UI and for CLI as well. Installing Python with Mesos should be responsibility of binary packages (Mesos could be build without UI), therefore this behaviour is not enabled by default.

You can enable this feature with following:

```puppet
class{'mesos':
  manage_python => true
}
```

or change Python package name, to match your needs:

```puppet
class{'mesos':
  manage_python => true,
  python_package => 'python-dev'
}
```


### Software repository

Software repositories could be enabled by defining a source:

```yaml
mesos::repo: 'mesosphere'
```

or in Puppet code:

```puppet
class{'mesos':
  repo => 'mesosphere'
}
```

by default this feature is disabled and right we support [mesosphere.io](http://mesosphere.io) repositories for:

  * Debian/Ubuntu
  * RedHat

Feel free to send PR for other distributions/package sources.

### Overriding service providers

Some Mesos packages does not respect conventions on given OS for starting services. For both `mesos::master` and `mesos::slave` you can specify mechanism which will be used for starting services.

```puppet
class{'mesos::master':
  force_provider => 'upstart'
}
```

If you want to create the service resource yourself, set `force_provider` to `none`.

Some reasonable values are:

  * `init`
  * `upstart` - e.g. Ubuntu
  * `systemd`
  * `runit`
  * `none`

### Packages

You can build package by yourself and upload package to your software repository. Or use packages from mesosphere.io:

  * Debian/Ubuntu
    * [mesos deb packaging](https://github.com/deric/mesos-deb-packaging)
    * [mesosphere packages](http://mesosphere.io/downloads/)
  * RedHat/CentOS
    * [mesosphere packages](http://mesosphere.io/downloads/)

## Requirements

  * Puppet > 2.6

## Dependencies

  * [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) version `>= 4.2.0` - we need function `is_bool`

## Installation

Preferred installation is via [puppet-librarian](https://github.com/rodjek/librarian-puppet) just add to `Puppetfile`:

```ruby
mod 'deric/mesos', '>= 0.4.0'
```

for latest version from git:
```ruby
mod 'deric/mesos', :git => 'git://github.com/deric/puppet-mesos.git'
```

## Links

For more information see [Mesos project](http://mesos.apache.org/)

## License

Apache License 2.0
