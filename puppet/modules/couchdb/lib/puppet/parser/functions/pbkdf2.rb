#
# pbkdf2.rb
#

module Puppet::Parser::Functions
  newfunction(:pbkdf2, :type => :rvalue, :doc => <<-EOS
This converts a password and a salt (and optional iterations and keylength
parameters) to a hash containing the salted SHA1 password hash, salt,
iterations and keylength.
pbkdf2 is used i.e. for couchdb passwords since v1.3.

Example usage:
  $pbkdf2 = pbkdf2($::couchdb::admin_pw, $::couchdb::admin_salt)
  $sha1   = $pbkdf2['sha1']
EOS
  ) do |arguments|
    require 'openssl'
    require 'base64'

    raise(Puppet::ParseError, "pbkdf2(): Wrong number of arguments " +
      "passed (#{arguments.size} but we require at least 2)") if arguments.size < 2

    unless arguments.is_a?(Array)
      raise(Puppet::ParseError, 'pbkdf2(): Requires a ' +
        "Array argument, you passed: #{password.class}")
    end

    password   = arguments[0]
    salt       = arguments[1]

    if arguments.size > 2
      iterations = arguments[2].to_i
    else
      iterations = 1000
    end

    if arguments.size > 3
      keylength  = arguments[3].to_i
    else
      keylength  = 20
    end

    pbkdf2 = OpenSSL::PKCS5::pbkdf2_hmac_sha1(
      password,
      salt,
      iterations,
      keylength
    )

    return_hash = Hash.new()
    # return hex encoded string
    return_hash['sha1']       = pbkdf2.unpack('H*')[0]
    return_hash['password']   = password
    return_hash['salt']       = salt
    return_hash['iterations'] = iterations
    return_hash['keylength']  = keylength

    return return_hash
  end
end

# vim: set ts=2 sw=2 et :
