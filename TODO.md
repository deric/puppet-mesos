= TODO

* When the slave configuration is changed the file
  */tmp/mesos/meta/slaves/latest* should be removed.
  Or, even better, the slave should be started with *--recover=cleanup*
  and, when all executors have been cleaned, restarted back with
  *--recover=reconnect*. We should invent a way to do this to
  prevent a slave being unable to start after online reconfiguration.
* Move all default values to the params class. Inherit all classes from
  the params class and pass custom values from the main class.
* Rename all parameters to the recommended style *entity_property*
  i.e. *config_file_path*, *config_file_mode*.
* Introduce some acceptance testing
* Rewrite specs to the modern syntax
