#
# str_and_salt2sha1.rb 
#

module Puppet::Parser::Functions
  newfunction(:str_and_salt2sha1, :type => :rvalue, :doc => <<-EOS
This converts a string to an array containing the salted SHA1 password hash in
the first field, and the salt itself in second field of the returned array. 
This combination is used i.e. for couchdb passwords.
    EOS
  ) do |arguments|
    require 'digest/sha1'

    raise(Puppet::ParseError, "str_and_salt2sha1(): Wrong number of arguments " +
      "passed (#{arguments.size} but we require 1)") if arguments.size != 1

    str_and_salt = arguments[0]

    unless str_and_salt.is_a?(Array)
      raise(Puppet::ParseError, 'str_and_salt2sha1(): Requires a ' +
        "Array argument, you passed: #{password.class}")
    end

    str  = str_and_salt[0]
    salt = str_and_salt[1]
    sha1 = Digest::SHA1.hexdigest(str+ salt)

    return sha1
  end
end

# vim: set ts=2 sw=2 et :
