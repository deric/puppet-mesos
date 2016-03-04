module Puppet::Parser::Functions
  newfunction(:zookeeper_servers_url, :type => :rvalue, :doc => <<-EOS
This function converts an array of zookeeper hostnames into a combined URL for
zookeeper HA.
EOS
  ) do |args|

    # Only 1 argument should be passed
    if args.size > 2
      raise(Puppet::ParseError, 'zookeeper_servers_url(): Wrong number of args ' + "given (#{args.size} for 1)")
    end

    zk_path = args[1] if args.size == 2
    zk_path ||= 'mesos'

    # The argument should be an Array
    case args[0].class.name
      when 'Array'
        zookeeper_servers = args[0].clone
      when 'String'
        # backward compatibility, will be removed in 1.x
        return args[0]
      else
        raise(Puppet::ParseError, 'zookeeper_servers_url() accepts an Array, you passed a ' + args[0].class.name)
    end

    return 'zk://' + zookeeper_servers.join(',') + '/' + zk_path
  end
end

