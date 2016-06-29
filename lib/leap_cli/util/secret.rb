# encoding: utf-8
#
# A simple secret generator
#
# Uses OpenSSL random number generator instead of Ruby's rand function
#
autoload :OpenSSL, 'openssl'

module LeapCli; module Util
  class Secret
    CHARS = (('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a) - "i1loO06G".split(//u)
    HEX = (0..9).to_a + ('a'..'f').to_a

    #
    # generate a secret with with no ambiguous characters.
    #
    # +length+ is in chars
    #
    # Only alphanumerics are allowed, in order to make these passwords work
    # for REST url calls and to allow you to easily copy and paste them.
    #
    def self.generate(length = 16)
      seed
      OpenSSL::Random.random_bytes(length).bytes.to_a.collect { |byte|
        CHARS[ byte % CHARS.length ]
      }.join
    end

    #
    # generates a hex secret, instead of an alphanumeric on.
    #
    # length is in bits
    #
    def self.generate_hex(length = 128)
      seed
      OpenSSL::Random.random_bytes(length/4).bytes.to_a.collect { |byte|
        HEX[ byte % HEX.length ]
      }.join
    end

    private

    def self.seed
      @pid ||= 0
      pid = $$
      if @pid != pid
        now = Time.now
        ary = [now.to_i, now.nsec, @pid, pid]
        OpenSSL::Random.seed(ary.to_s)
        @pid = pid
      end
    end

  end
end; end
