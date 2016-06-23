#
# A wrapper around OpenSSL::PKey::RSA instances to provide a better api for
# dealing with SSH keys.
#
# NOTE: cipher 'ssh-ed25519' not supported yet because we are waiting
# for support in Net::SSH
#

require 'net/ssh'
require 'forwardable'

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

      ##
      ## INSTANCE METHODS
      ##

      public

      def initialize(rsa_key)
        @key = rsa_key
      end

      def_delegator :@key, :fingerprint, :fingerprint
      def_delegator :@key, :public?, :public?
      def_delegator :@key, :private?, :private?
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

      #
      # not sure if this will always work, but is seems to for now.
      #
      def bits
        Net::SSH::Buffer.from(:key, @key).to_s.split("\001\000").last.size * 8
      end

      def summary
        if self.filename
          "%s %s %s (%s)" % [self.type, self.bits, self.fingerprint, File.basename(self.filename)]
        else
          "%s %s %s" % [self.type, self.bits, self.fingerprint]
        end
      end

      def to_s
        self.type + " " + self.key
      end

      def key
        [Net::SSH::Buffer.from(:key, @key).to_s].pack("m*").gsub(/\s/, "")
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
