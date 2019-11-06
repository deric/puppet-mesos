#
# mesos_hash_parser.rb
#

module Puppet::Parser::Functions
  newfunction(:mesos_hash_parser, type: :rvalue, doc: <<-EOS
This function converts simple key-value structure to a Hash
that is required by create_resources function

  EOS
             ) do |args|

    # Arguments: hash key_prefix [file_prefix]

    if args.empty? || args.size > 3
      raise(Puppet::ParseError, "mesos_hash_parser(): Wrong number of args, given #{args.size}, accepts either 1, 2 or 3")
    end

    if args[0].class != Hash
      raise(Puppet::ParseError, 'mesos_hash_parser(): first argument must be a Hash, you passed a ' + args[0].class.to_s)
    end

    res = {}
    key_prefix = args[1] if args.size >= 2
    file_prefix = args[2] if args.size == 3
    args[0].each do |key, val|
      file = file_prefix ? "#{file_prefix}_#{key}" : key
      key = "#{key_prefix}_#{key}" if key_prefix
      res[key] = {
        'value' => val,
        'file' => file
      }
    end
    res
  end
end
