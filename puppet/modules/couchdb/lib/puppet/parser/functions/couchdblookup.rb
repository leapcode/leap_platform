#
# A basic function to retrieve data in couchdb
#


module Puppet::Parser::Functions
  newfunction(:couchdblookup, :type => :rvalue) do |args|
    require 'json'
    require 'open-uri'

    raise Puppet::ParseError, ("couchdblookup(): wrong number of arguments (#{args.length}; must be 2 or 3)") unless args.length.between?(2, 3)

    url = args[0]
    key = args[1]
    default = args[2] if args.length >= 3

    begin
      json = JSON.parse(open(URI.parse(url)).read)
    rescue OpenURI::HTTPError => error
      raise Puppet::ParseError, "couchdblookup(): fetching URL #{url} failed with status '#{error.message}'"
    rescue Timeout::Error => error
      raise Puppet::ParseError, "couchdblookup(): connection to couchdb server timed out: '#{error.message}'"
    rescue Errno::ECONNREFUSED => error
      raise Puppet::ParseError, "couchdblookup(): connection to couchdb server failed: '#{error.message}'"
    rescue JSON::ParserError => error
      raise Puppet::ParseError, "couchdblookup(): failed to parse JSON received from couchdb: '#{error.message}'"
    rescue StandardError => error
      raise Puppet::ParseError, "couchdblookup(): something unexpected happened: '#{error.inspect}'"
    end

    result = nil

    if json.has_key?("rows")

      if json['rows'].length > 1
        arr = json['rows'].collect do |x|
          x[key] if x.is_a?(Hash) and x.has_key?(key)
        end
        arr.compact!
        result = arr unless arr.empty?

      elsif json['rows'].length == 1
        hash = json['rows'].pop
        result = hash[key] if hash.is_a?(Hash)
      end

    elsif json.has_key?(key)
      result = json[key]
    end

    result or default or raise Puppet::ParseError, "couchdblookup(): key '#{key}' not found in JSON object !"

  end
end

