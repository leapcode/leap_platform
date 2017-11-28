#
# A wrapper around OpenSSL::PKey::RSA instances to provide a better api for
# dealing with SSH keys.
#
# NOTES:
#
# cipher 'ssh-ed25519' not supported yet because we are waiting
# for support in Net::SSH
#
# there are many ways to represent an SSH key, since SSH keys can be of
# a variety of types.
#
# To confuse matters more, there are multiple binary representations.
# So, for example, an RSA key has a native SSH representation
# (two bignums, e followed by n), and a DER representation.
#
# AWS uses fingerprints of the DER representation, but SSH typically reports
# fingerprints of the SSH representation.
#
# Also, SSH public key files are base64 encoded, but with whitespace removed
# so it all goes on one line.
#
# Some useful links:
#
# https://stackoverflow.com/questions/3162155/convert-rsa-public-key-to-rsa-der
# https://net-ssh.github.io/ssh/v2/api/classes/Net/SSH/Buffer.html
# https://serverfault.com/questions/603982/why-does-my-openssh-key-fingerprint-not-match-the-aws-ec2-console-keypair-finger
#

require 'net/ssh'
require 'forwardable'
require 'base64'

module LeapCli
  module SSH
    class Key
      extend Forwardable

      attr_accessor :filename
      attr_accessor :comment

      # supported ssh key types, in order of preference
      SUPPORTED_TYPES = ['ssh-rsa', 'ecdsa-sha2-nistp256']
      SUPPORTED_TYPES_RE = /(#{SUPPORTED_TYPES.join('|')})/

      ##
      ## CLASS METHODS
      ##

      def self.load(arg1, arg2=nil)
        key = nil
        if arg1.is_a? OpenSSL::PKey::RSA
          key = Key.new arg1
        elsif arg1.is_a? String
          if arg1 =~ /^ssh-/
            type, data = arg1.split(' ')
            key = Key.new load_from_data(data, type)
          elsif File.exist? arg1
            key = Key.new load_from_file(arg1)
            key.filename = arg1
          else
            key = Key.new load_from_data(arg1, arg2)
          end
        end
        return key
      rescue StandardError
      end

      def self.load_from_file(filename)
        public_key = nil
        private_key = nil
        begin
          public_key = Net::SSH::KeyFactory.load_public_key(filename)
        rescue NotImplementedError, Net::SSH::Exception, OpenSSL::PKey::PKeyError
          begin
            private_key = Net::SSH::KeyFactory.load_private_key(filename)
          rescue NotImplementedError, Net::SSH::Exception, OpenSSL::PKey::PKeyError
          end
        end
        public_key || private_key
      end

      def self.load_from_data(data, type='ssh-rsa')
        public_key = nil
        private_key = nil
        begin
          public_key = Net::SSH::KeyFactory.load_data_public_key("#{type} #{data}")
        rescue NotImplementedError, Net::SSH::Exception, OpenSSL::PKey::PKeyError
          begin
            private_key = Net::SSH::KeyFactory.load_data_private_key("#{type} #{data}")
          rescue NotImplementedError, Net::SSH::Exception, OpenSSL::PKey::PKeyError
          end
        end
        public_key || private_key
      end

      def self.my_public_keys
        load_keys_from_paths File.join(ENV['HOME'], '.ssh', '*.pub')
      end

      def self.provider_public_keys
        load_keys_from_paths Path.named_path([:user_ssh, '*'])
      end

      #
      # Picks one key out of an array of keys that we think is the "best",
      # based on the order of preference in SUPPORTED_TYPES
      #
      # Currently, this does not take bitsize into account.
      #
      def self.pick_best_key(keys)
        keys.select {|k|
          SUPPORTED_TYPES.include?(k.type)
        }.sort {|a,b|
          SUPPORTED_TYPES.index(a.type) <=> SUPPORTED_TYPES.index(b.type)
        }.first
      end

      #
      # takes a string with one or more ssh keys, one key per line,
      # and returns an array of Key objects.
      #
      # the lines should be in one of these formats:
      #
      # 1. <hostname> <key-type> <key>
      # 2. <key-type> <key>
      #
      def self.parse_keys(string)
        keys = []
        lines = string.split("\n").grep(/^[^#]/)
        lines.each do |line|
          if line =~ / #{Key::SUPPORTED_TYPES_RE} /
            # <hostname> <key-type> <key>
            keys << line.split(' ')[1..2]
          elsif line =~ /^#{Key::SUPPORTED_TYPES_RE} /
            # <key-type> <key>
            keys << line.split(' ')
          end
        end
        return keys.map{|k| Key.load(k[1], k[0])}
      end

      #
      # takes a string with one or more ssh keys, one key per line,
      # and returns a string that specified the ssh key algorithms
      # that are supported by the keys, in order of preference.
      #
      # eg: ecdsa-sha2-nistp256,ssh-rsa,ssh-ed25519
      #
      def self.supported_host_key_algorithms(string)
        if string
          self.parse_keys(string).map {|key|
            key.type
          }.join(',')
        else
          ""
        end
      end

      private

      def self.load_keys_from_paths(key_glob)
        keys = []
        Dir.glob(key_glob).each do |file|
          key = Key.load(file)
          if key && key.public?
            keys << key
          end
        end
        return keys
      end

      ##
      ## INSTANCE METHODS
      ##

      public

      def initialize(p_key)
        @key = p_key
      end

      def_delegator :@key, :ssh_type, :type
      def_delegator :@key, :public_encrypt, :public_encrypt
      def_delegator :@key, :public_decrypt, :public_decrypt
      def_delegator :@key, :private_encrypt, :private_encrypt
      def_delegator :@key, :private_decrypt, :private_decrypt
      def_delegator :@key, :params, :params
      def_delegator :@key, :to_text, :to_text

      def public_key
        Key.new(@key.public_key)
      end

      def private_key
        Key.new(@key.private_key)
      end

      def private?
        @key.respond_to?(:private?) ? @key.private? : @key.private_key?
      end

      def public?
        @key.respond_to?(:public?) ? @key.public? : @key.public_key?
      end

      #
      # three arguments:
      #
      # - digest: one of md5, sha1, sha256, etc. (default sha256)
      # - encoding: either :hex (default) or :base64
      # - type: fingerprint type, either :ssh (default) or :der
      #
      # NOTE:
      #
      # * I am not sure how to make a fingerprint for OpenSSL::PKey::EC::Point
      #
      # * AWS reports fingerprints using MD5 digest for uploaded ssh keys,
      #   but SHA1 for keys it created itself.
      #
      # * Also, AWS fingerprints are digests on the DER encoding of the key.
      #   But standard SSH fingerprints are digests of SSH encoding of the key.
      #
      # * Other tools will sometimes display fingerprints in hex and sometimes
      #   in base64. Arrrgh.
      #
      def fingerprint(type: :ssh, digest: :sha256, encoding: :hex)
        require 'digest'

        digest = digest.to_s.upcase
        digester = case digest
          when "MD5" then Digest::MD5.new
          when "SHA1" then Digest::SHA1.new
          when "SHA256" then Digest::SHA256.new
          when "SHA384" then Digest::SHA384.new
          when "SHA512" then Digest::SHA512.new
          else raise ArgumentError, "digest #{digest} is unknown"
        end

        keymatter = nil
        if type == :der && @key.respond_to?(:to_der)
          keymatter = @key.to_der
        else
          keymatter = self.raw_key.to_s
        end

        fp = nil
        if encoding == :hex
          fp = digester.hexdigest(keymatter)
        elsif encoding == :base64
          fp = Base64.encode64(digester.digest(keymatter)).sub(/=$/, '')
        else
          raise ArgumentError, "encoding #{encoding} not understood"
        end

        if digest == "MD5" && encoding == :hex
          return fp.strip.scan(/../).join(':')
        else
          return fp.strip
        end
      end

      #
      # not sure if this will always work, but is seems to for now.
      #
      def bits
        Net::SSH::Buffer.from(:key, @key).to_s.split("\001\000").last.size * 8
      end

      def summary(type: :ssh, digest: :sha256, encoding: :hex)
        fp = digest.to_s.upcase + ":" + self.fingerprint(type: type, digest: digest, encoding: encoding)
        if self.filename
          "%s %s %s (%s)" % [self.type, self.bits, fp, File.basename(self.filename)]
        else
          "%s %s %s" % [self.type, self.bits, fp]
        end
      end

      def to_s
        self.type + " " + self.key
      end

      #
      # base64 encoding of the key, with spaces removed.
      #
      def key
        [Net::SSH::Buffer.from(:key, @key).to_s].pack("m*").gsub(/\s/, "")
      end

      def raw_key
        Net::SSH::Buffer.from(:key, @key)
      end

      def ==(other_key)
        return false if other_key.nil?
        return false if self.class != other_key.class
        return self.to_text == other_key.to_text
      end

      def in_known_hosts?(*identifiers)
        identifiers.each do |identifier|
          Net::SSH::KnownHosts.search_for(identifier).each do |key|
            return true if self == key
          end
        end
        return false
      end

    end
  end
end
