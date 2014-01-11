
#
# mesos_hash_parser.rb
#

module Puppet::Parser::Functions
  newfunction(:mesos_hash_parser, :type => :rvalue, :doc => <<-EOS
This function reduces a hash of arguments

*Examples:*

*TODO*
        EOS
  ) do |arguments|

    # Only 1 argument should be passed
    raise(Puppet::ParseError, "mesos_hash_parser(): Wrong number of arguments " +         "given (#{arguments.size} for 1)") if arguments.size != 1

    # The argument should be a Hash
    raise(Puppet::ParseError, "mesos_hash_parser() accepts a Hash, you passed a " + arguments[0].class) if arguments[0].class != Hash

    res = {}
    arguments[0].each do |key, val|
      res[key] = {
        "value" => val
      }
    end
    res
  end
end