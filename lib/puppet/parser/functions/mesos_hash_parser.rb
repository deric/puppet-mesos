
#
# mesos_hash_parser.rb
#

module Puppet::Parser::Functions
  newfunction(:mesos_hash_parser, :type => :rvalue, :doc => <<-EOS
This function converts simple key-value structure to a Hash
that is required by create_resources function

        EOS
  ) do |arguments|

    # Only 1 argument should be passed
    if arguments.size < 1 || arguments.size > 2
      raise(Puppet::ParseError, "mesos_hash_parser(): Wrong number of arguments " + "given (#{arguments.size} for 1)")
    end

    # The argument should be a Hash
    if arguments[0].class != Hash
      raise(Puppet::ParseError, "mesos_hash_parser() accepts a Hash, you passed a " + arguments[0].class)
    end

    res = {}
    prefix = arguments[1] if arguments.size == 2
    arguments[0].each do |key, val|
      key = "#{prefix}_#{key}" if prefix
      res[key] = {
        "value" => val
      }
    end
    res
  end
end