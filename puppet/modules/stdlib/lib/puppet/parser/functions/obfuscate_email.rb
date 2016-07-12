module Puppet::Parser::Functions
  newfunction(:obfuscate_email, :type => :rvalue, :doc => <<-EOS
Given:
  a comma seperated email string in form of 'john@doe.com, doe@john.com'

This function will return all emails obfuscated in form of 'john {at} doe {dot} com, doe {at} john {dot} com' 
Works with multiple email adresses as well as with a single email adress.

    EOS
  ) do |args|
      args[0].gsub('@', ' {at} ').gsub('.', ' {dot} ')
    end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
