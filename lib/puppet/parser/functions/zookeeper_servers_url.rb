module Puppet::Parser::Functions
  newfunction(:zookeeper_servers_url, type: :rvalue, doc: <<-EOS
This function converts an array of ZooKeeper hostnames into a combined URL for
ZooKeeper HA. Optionally you can pass custom path in ZooKeeper and default
ZooKeeper port (applies only for servers without specified port)

Usage: zookeeper_servers_url([10.0.0.1,10.0.0.2],'mesos', 2181)
  EOS
) do |args|

    # Only 1 argument should be passed
    if args.size > 3
      raise(Puppet::ParseError, 'zookeeper_servers_url(): Wrong number of args ' + "given (#{args.size} for 1)")
    end

    zk_path = args[1] if args.size > 1
    zk_path ||= 'mesos'
    zk_port = args[2] if args.size > 2
    zk_port ||= 2181

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

    uri = 'zk://'
    zookeeper_servers.each_with_index do |server, i|
      uri << ',' if i > 0
      uri << if server.index(':')
               server
             else
               "#{server}:#{zk_port}"
             end
    end
    return "#{uri}/#{zk_path}"
  end
end
