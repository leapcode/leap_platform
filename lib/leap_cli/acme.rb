require 'openssl'
require 'acme-client'

#
# A little bit of sugar around gem acme-client
#

module LeapCli
  class Acme

    if ENV['ACME_STAGING']
      ENDPOINT = 'https://acme-staging.api.letsencrypt.org/'
      puts "using endpoint " + ENDPOINT
    else
      ENDPOINT = 'https://acme-v01.api.letsencrypt.org/'
    end

    def initialize(domain: nil, key:)
      @client = ::Acme::Client.new(
        private_key: key,
        endpoint: ENDPOINT,
        connection_options: {request: {open_timeout: 5, timeout: 5}}
      )
      @domain = domain
    end

    #
    # static methods
    #

    def self.new_private_key
      return OpenSSL::PKey::RSA.new(4096)
    end

    def self.load_private_key(pem_encoded_key)
      return OpenSSL::PKey::RSA.new(pem_encoded_key)
    end

    def self.load_csr(pem_encoded_csr)
      return OpenSSL::X509::Request.new(pem_encoded_csr)
    end

    #
    # instance methods
    #

    #
    # register a new account key with CA
    #
    def register(contact)
      registration = @client.register(contact: 'mailto:' + contact)
      if registration && registration.agree_terms
        return registration
      else
        return false
      end
    end

    #
    # authorize account key for domain
    #
    def authorize
      authorization = @client.authorize(domain: @domain)
      challenge = nil
      begin
        while true
          if authorization.status == 'pending'
            challenge = authorization.http01
            yield challenge
            challenge.request_verification
            sleep 1
            authorization.verify_status
            if challenge.error
              return 'error', challenge.error
            end
          elsif authorization.status == 'invalid'
            challenge_msg = (challenge.nil? ? '' : challenge.error)
            return 'error', 'Something bad happened. %s' % challenge_msg
          elsif authorization.status == 'valid'
            return 'valid', nil
          else
            challenge_msg = (challenge.nil? ? '' : challenge.error)
            return 'error', 'status: %s, response message: %s' % [authorization.status, challenge_msg]
          end
        end
      rescue Interrupt
        return 'error', 'interrupted'
      end
    rescue ::Acme::Client::Error::Unauthorized => exc
      return 'unauthorized', exc.to_s
    end

    #
    # get new certificate
    #
    def get_certificate(csr)
      return @client.new_certificate(csr)
    end

  end
end