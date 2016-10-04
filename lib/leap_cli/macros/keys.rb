# encoding: utf-8

#
# Macro for dealing with cryptographic keys
#

module LeapCli
  module Macro

    #
    # return a fingerprint for a key or certificate
    #
    def fingerprint(filename, options={})
      options[:mode] ||= :x509
      if options[:mode] == :x509
        "SHA256: " + X509.fingerprint("SHA256", Path.named_path(filename))
      elsif options[:mode] == :rsa
        key = OpenSSL::PKey::RSA.new(File.read(filename))
        Digest::SHA1.new.hexdigest(key.to_der)
      end
    end

    ##
    ## TOR
    ##

    #
    # return the path to the tor public key
    # generating key if it is missing
    #
    def tor_public_key_path(path_name, key_type)
      remote_file_path(path_name) { generate_tor_key(key_type) }
    end

    #
    # return the path to the tor private key
    # generating key if it is missing
    #
    def tor_private_key_path(path_name, key_type)
      remote_file_path(path_name) { generate_tor_key(key_type) }
    end

    #
    # Generates a onion_address from a public RSA key file.
    #
    # path_name is the named path of the Tor public key.
    #
    # Basically, an onion address is nothing more than a base32 encoding
    # of the first 10 bytes of a sha1 digest of the public key.
    #
    # Additionally, Tor ignores the 22 byte header of the public key
    # before taking the sha1 digest.
    #
    def onion_address(path_name)
      require 'base32'
      require 'base64'
      require 'openssl'
      path = Path.named_path([path_name, self.name])
      if path && File.exist?(path)
        public_key_str = File.readlines(path).grep(/^[^-]/).join
        public_key     = Base64.decode64(public_key_str)
        public_key     = public_key.slice(22..-1) # Tor ignores the 22 byte SPKI header
        sha1sum        = Digest::SHA1.new.digest(public_key)
        Base32.encode(sha1sum.slice(0,10)).downcase
      else
        LeapCli.log :warning, 'Tor public key file "%s" does not exist' % path
      end
    end

    def generate_dkim_key(bit_size=2048)
      LeapCli.log :generating, "%s bit RSA DKIM key" % bit_size do
        private_key = OpenSSL::PKey::RSA.new(bit_size)
        public_key = private_key.public_key
        LeapCli::Util.write_file! :dkim_priv_key, private_key.to_pem
        LeapCli::Util.write_file! :dkim_pub_key, public_key.to_pem
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
