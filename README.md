#puppet-mesos

This is a puppet module for managing mesos nodes in a cluster.

## Requirements
  
  * Puppet 3 (or 2.6 with hiera gem)
  * mesos binary package, for Debian see [mesos deb packaging](https://github.com/deric/mesos-deb-packaging)

## Usage
  
  Should be as simple as this, on master node:

      include mesos::master

  On slave:

      include mesos::slave

  Configuration should be handled by hiera. 
   
  TODO: add hiera example

## Links

For more information see [Mesos project](http://mesos.apache.org/)

## License

Apache License 2.0

