# Mesos Puppet Module
[![Puppet
Forge](http://img.shields.io/puppetforge/v/deric/mesos.svg)](https://forge.puppetlabs.com/deric/mesos) [![Build Status](https://travis-ci.org/deric/puppet-mesos.png)](https://travis-ci.org/deric/puppet-mesos) [![Puppet Forge
Downloads](http://img.shields.io/puppetforge/dt/deric/mesos.svg)](https://forge.puppetlabs.com/deric/mesos/scores)

*COMPATIBILITY NOTE:* current version (0.6.x) requires `puppetlabs-apt >= 2.1.0` which has significantly refactored API (doesn't matter if you don't wanna use Mesosphere APT repo).

For installing master

```puppet
class{'mesos':
  repo => 'mesosphere',
  zookeeper => [ '192.168.1.1', '192.168.1.2', '192.168.1.3'],
}

class{'mesos::master':
  work_dir => '/var/lib/mesos',
  options => {
    quorum   => 2
  }
}
```
From ZooKeeper array an URI is created `zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos`. In order to customize this use either `server:port` or see `zk_path` and `zk_default_port` variable.

Example slave configuration:

```puppet
class{'mesos::slave':
  attributes => {
    'env' => 'production',
  },
  resources => {
    'ports' => '[10000-65535]'
  },
  options   => {
    'isolation'      => 'cgroups/cpu,cgroups/mem',
    'containerizers' => 'docker,mesos',
    'hostname'       => $::fqdn,
  }
}
```

for using Hiera and other options see below.


## Shared parameters

Parameters:

 - `zookeeper` - Array of ZooKeeper servers (with port) which is used for slaves connecting to the master and also for leader election, e.g.:
   - single ZooKeeper: `127.0.0.1:2181` (which isn't fault tolerant)
        - multiple ZooKeepers: `[ '192.168.1.1:2181', '192.168.1.2:2181', '192.168.1.3:2181']` (usually 3 or 5 ZooKeepers should be enough)
        - ZooKeeper URL will be stored in `/etc/mesos/zk`, `/etc/default/mesos-master` and/or `/etc/default/mesos-slave`
 - `conf_dir` - directory with simple configuration files containing master/slave parameters (name of the file is a key, contents its value)
        - this directory will be completely managed by Puppet
 - `env_var` - shared master/slave execution environment variables (see example under slave)
 - `version` - install specific version of Mesos
 - `manage_python` - Control whether mesos module should install python
 - `manage_zk_file` - Control whether module manages /etc/mesos/zk (default: true)
 - `manage_service` - Whether Puppet should ensure service state (applies to `mesos-master` and `mesos-slave`) (default: `true`)
 - `single_role` - When enabled each machine is expected to run either master or slave service (default: `true`)

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
  zookeeper => ['192.168.1.1:2181', '192.168.1.2:2181', '192.168.1.3:2181']
}
```
 - `conf_dir` default value is `/etc/mesos-master` (this directory will be purged by Puppet!)
 	- for list of supported options see `mesos-master --help`
 - `env_var` - master's execution environment variables (see example under slave)
 - `acls` - hash of mesos acls, `{"permissive" => true, "register_frameworks" => [..]}` (default: `{}`)
 - `acls_file` - path to file to store acls (default: `/etc/mesos/acls`)
 - `credentials` - array of mesos credentials, `[{'principal' => 'some-principal', 'secret' => 'some-secret'}]` (default: `[]`)
 - `credentials_file` - path to file to store credentials (default: `/etc/mesos/master-credentials`)
 - `syslog_logger` - whether to log the Mesos service's output to syslog - note that if this parameter is false then it is up to your init system to log the process's output and if Mesos fails to start properly it will not produce log files of its own (default: true)

#### listen address

By default Mesos will bind to `0.0.0.0`. If you want to change the IP address Mesos is binding to, you can either provide a Puppet Fact:

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

Note that Facter 2 will contain incorrect IP address in `$::ipaddress` fact when Docker is installed. See [FACT-380](https://tickets.puppetlabs.com/browse/FACT-380) for more information.

By default no IP address is set, which means that Mesos will use IP to which translates `hostname -f` (you can influence bind address simply in `/etc/hosts`).


### Slave

 - `enable` - install Mesos slave service (default: `true`)
 - `port` - slave's port for incoming connections (default: `5051`)
 - `master`- ip address of Mesos master (default: `localhost`)
 - `master_port` - Mesos master's port (default: `5050`)
 - `work_dir` - directory for storing task's temporary files (default: `/tmp/mesos`)
 - `env_var` - slave's execution environment variables - a Hash, if you are using
 Java, you might need e.g.:
 - `principal` - mesos principal used for auththentication
 - `secret` - secret used for auththentication
 - `credentials_file` - path to file to store credentials (default: `/etc/mesos/slave-credentials`)
 - `syslog_logger` - whether to log the Mesos service's output to syslog (default: true)

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

As Mesos configuration flags changes with each version we don't provide directly a named parameter for each flag. `mesos::property` allows to create a parameter file. e.g. configure value in `/etc/mesos-slave/hostname`:

```puppet
mesos::property { 'hostname':
  value  => 'mesos.hostname.com',
  dir    => '/etc/mesos-slave',
  notify => Service['mesos-slave']
}
```

Remove this file simply use the `ensure` parameter:

```puppet
mesos::property { 'hostname':
  ensure => absent,
  dir    => '/etc/mesos-slave',
  notify => Service['mesos-slave']
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

## Mesos Standalone

Standalone mode (non-HA) is useful for testing, it does not require ZooKeeper URI, nor `quorum` variable. If you are running both master and slave on the same node, make sure you disable `single_role` parameter:

```puppet
class{'::mesos':
  single_role => false,
}
```

## Hiera support

All configuration could be handled by Hiera. Simple parameter are looked up by default in Puppet 3, however hashes won't get merged. In order to merge options from multiple Hiera files set `mesos::use_hiera: true`.

Either specify one master

```yaml
mesos::master      : '192.168.1.1'
```

  or [Zookeeper](http://zookeeper.apache.org/) could be use for a fault-tolerant setup (multiple instances of zookeeper are separated by comma):

```yaml
mesos::zookeeper:
  - '192.168.1.1:2181'
  - '192.168.1.2:2181'
  - '192.168.1.3:2181'
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

### Mesos CLI

Mesos command line interface is written in Python (currently supports 2.6 and 2.7). The CLI provides serveral useful commands like `mesos ps` ,`mesos ls`. For complete list see [CLI documentation](https://pypi.python.org/pypi/mesos.cli).

By default CLI is not installed with master nor slave, you should enable this manually by including

```puppet
class{'mesos::cli':
  debug            => false,
  response_timeout => 5,
}
```

on any machine that can connect to mesos-master and mesos-slaves.


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
  * RedHat/CentOS

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
  * `none` - service won't be installed

### Packages

You can build package by yourself and upload package to your software repository. Or use packages from mesosphere.io:

  * Debian/Ubuntu
    * [mesosphere packages](http://mesosphere.io/downloads/)
  * RedHat/CentOS
    * [mesosphere packages](http://mesosphere.io/downloads/)

## Requirements

  * Puppet > 3.0 and < 5.0

## Dependencies

  * [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) version `>= 4.2.0` - we need function `is_bool`
  * [apt](https://github.com/puppetlabs/puppetlabs-apt) version `>= 2.1.0` is required for Debian servers (since puppet-mesos 0.6)

## Installation

Preferred installation is via [puppet-librarian](https://github.com/rodjek/librarian-puppet) just add to `Puppetfile`:

```ruby
mod 'deric/mesos', '>= 0.6.0'
```

for latest version from git:
```ruby
mod 'deric/mesos', :git => 'git://github.com/deric/puppet-mesos.git'
```

## Links

For more information see [Mesos project](http://mesos.apache.org/)

## License

Apache License 2.0


## Contributors

Alphabetical list of contributors (not necessarily up-to-date), generated by command `git log --format='%aN' | sort -u | sed -e 's/^/\- /'`:

- Andrew Teixeira
- Chris Rebert
- Felix Bechstein
- Ian Burrell
- Jamie Hewland
- jfarrell
- Jing Dong
- Konrad Scherer
- krall
- Kyle Anderson
- Maksym Melnychok
- Oriol Fitó
- Paul Otto
- Rhommel Lamas
- Sam Stoelinga
- Sean McLaughlin
- Sophie Haskins
- Tadas Vilkeliskis
- taik0
- Tomas Barton
- Tom Stockton
- William Leese
