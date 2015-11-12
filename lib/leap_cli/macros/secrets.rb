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
      manager.secrets.set(name, @node.environment) { Util::Secret.generate(length) }
    end

    # inserts a base32 encoded secret
    def base32_secret(name, length=20)
      manager.secrets.set(name, @node.environment) { Base32.encode(Util::Secret.generate(length)) }
    end

    # Picks a random obfsproxy port from given range
    def rand_range(name, range)
      manager.secrets.set(name, @node.environment) { rand(range) }
    end

    #
    # inserts an hexidecimal secret string, generating it if needed.
    #
    # +bit_length+ is the bits in the secret, (ie length of resulting hex string will be bit_length/4)
    #
    def hex_secret(name, bit_length=128)
      manager.secrets.set(name, @node.environment) { Util::Secret.generate_hex(bit_length) }
    end

  end
end