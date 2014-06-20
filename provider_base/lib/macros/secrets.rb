# encoding: utf-8

require 'base32'

module LeapCli
  module Macro

    #
    # inserts a named secret, generating it if needed.
    #
    # manager.export_secrets should be called later to capture any newly generated secrets.
    #
    # +length+ is the character length of the generated password.
    #
    def secret(name, length=32)
      @manager.secrets.set(name, Util::Secret.generate(length), @node[:environment])
    end

    # inserts a base32 encoded secret
    def base32_secret(name, length=20)
      @manager.secrets.set(name, Base32.encode(Util::Secret.generate(length)), @node[:environment])
    end

    # Picks a random obfsproxy port from given range
    def rand_range(name, range)
      @manager.secrets.set(name, rand(range), @node[:environment])
    end

    #
    # inserts an hexidecimal secret string, generating it if needed.
    #
    # +bit_length+ is the bits in the secret, (ie length of resulting hex string will be bit_length/4)
    #
    def hex_secret(name, bit_length=128)
      @manager.secrets.set(name, Util::Secret.generate_hex(bit_length), @node[:environment])
    end

  end
end