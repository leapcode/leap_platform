# encoding: utf-8

#
# Macro for dealing with cryptographic keys
#

module LeapCli
  module Macro

    #
    # return the path to the tor public key
    # generating key if it is missing
    #
    def tor_public_key_path(path_name, key_type)
      path = file_path(path_name)
      if path.nil?
        generate_tor_key(key_type)
        file_path(path_name)
      else
        path
      end
    end

    #
    # return the path to the tor private key
    # generating key if it is missing
    #
    def tor_private_key_path(path_name, key_type)
      path = file_path(path_name)
      if path.nil?
        generate_tor_key(key_type)
        file_path(path_name)
      else
        path
      end
    end

    #
    # on the command line an onion address can be created
    # from an rsa public key using this:
    #
    #   base64 -d < ./pubkey | sha1sum | awk '{print $1}' |
    #     perl -e '$l=<>; chomp $l; print pack("H*", $l)' |
    #     python -c 'import base64, sys; t=sys.stdin.read(); print base64.b32encode(t[:10]).lower()'
    #
    # path_name is the named path of the tor public key.
    #
    def onion_address(path_name)
      require 'base32'
      require 'base64'
      require 'openssl'
      path = Path.find_file([path_name, self.name])
      if path && File.exists?(path)
        public_key_str = File.readlines(path).grep(/^[^-]/).join
        public_key     = Base64.decode64(public_key_str)
        sha1sum_string = Digest::SHA1.new.hexdigest(public_key)
        sha1sum_binary = [sha1sum_string].pack('H*')
        Base32.encode(sha1sum_binary.slice(0,10)).downcase
      else
        LeapCli.log :warning, 'Tor public key file "%s" does not exist' % tor_public_key_path
      end
    end

    private

    def generate_tor_key(key_type)
      if key_type == 'RSA'
        require 'certificate_authority'
        keypair = CertificateAuthority::MemoryKeyMaterial.new
        bit_size = 1024
        LeapCli.log :generating, "%s bit RSA Tor key" % bit_size do
          keypair.generate_key(bit_size)
          LeapCli::Util.write_file! [:node_tor_priv_key, self.name], keypair.private_key.to_pem
          LeapCli::Util.write_file! [:node_tor_pub_key, self.name], keypair.public_key.to_pem
        end
      else
        LeapCli.bail! 'tor.key.type of %s is not yet supported' % key_type
      end
    end

  end
end
