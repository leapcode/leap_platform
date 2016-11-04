#
# str2saltedsha1.rb
#

module Puppet::Parser::Functions
  newfunction(:str2sha1_and_salt, :type => :rvalue, :doc => <<-EOS
This converts a string to an array containing the salted SHA1 password hash in
the first field, and the salt itself in second field of the returned array. 
This combination is used i.e. for couchdb passwords.
    EOS
  ) do |arguments|
    require 'digest/sha1'

    raise(Puppet::ParseError, "str2saltedsha1(): Wrong number of arguments " +
      "passed (#{arguments.size} but we require 1)") if arguments.size != 1

    password = arguments[0]

    unless password.is_a?(String)
      raise(Puppet::ParseError, 'str2saltedsha1(): Requires a ' +
        "String argument, you passed: #{password.class}")
    end

    seedint    = rand(2**31 - 1)
    seedstring = Array(seedint).pack("L")
    salt       = Digest::MD5.hexdigest(seedstring)
    saltedpass = Digest::SHA1.hexdigest(password + salt)

    array = Array.new
    array << saltedpass
    array << salt 
    return array 
  end
end

# vim: set ts=2 sw=2 et :
