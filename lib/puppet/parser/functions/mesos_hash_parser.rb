
#
# mesos_hash_parser.rb
#

module Puppet::Parser::Functions
  newfunction(:mesos_hash_parser, :type => :rvalue, :doc => <<-EOS
This function converts simple key-value structure to a Hash
that is required by create_resources function

        EOS
  ) do |args|

    # Only 1 argument should be passed
    if args.size < 1 || args.size > 2
      raise(Puppet::ParseError, "mesos_hash_parser(): Wrong number of args " + "given (#{args.size} for 1)")
    end

    # The argument should be a Hash
    if args[0].class != Hash
      raise(Puppet::ParseError, "mesos_hash_parser() accepts a Hash, you passed a " + args[0].class)
    end

    res = {}
    prefix = args[1] if args.size == 2
    args[0].each do |key, val|
      key = "#{prefix}_#{key}" if prefix
      res[key] = {
        "value" => val
      }
    end
    res
  end
end