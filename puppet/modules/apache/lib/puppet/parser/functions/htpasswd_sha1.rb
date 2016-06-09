require 'digest/sha1' 
require 'base64'

module Puppet::Parser::Functions
  newfunction(:htpasswd_sha1, :type => :rvalue) do |args|
    "{SHA}" + Base64.encode64(Digest::SHA1.digest(args[0]))
  end
end
