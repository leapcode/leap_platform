#
# Signing profiles are used by CertificateAuthority in order to
# set the correct flags when signing certificates.
#

module LeapCli; module X509

  #
  # For CA self-signing
  #
  def self.ca_root_signing_profile
    {
      "extensions" => {
        "basicConstraints" => {"ca" => true},
        "keyUsage" => {
          "usage" => ["critical", "keyCertSign"]
        },
        "extendedKeyUsage" => {
          "usage" => []
        }
      }
    }
  end

  #
  # For keyusage, openvpn server certs can have keyEncipherment or keyAgreement.
  # Web browsers seem to break without keyEncipherment.
  # For now, I am using digitalSignature + keyEncipherment
  #
  # * digitalSignature -- for (EC)DHE cipher suites
  #   "The digitalSignature bit is asserted when the subject public key is used
  #    with a digital signature mechanism to support security services other
  #    than certificate signing (bit 5), or CRL signing (bit 6). Digital
  #    signature mechanisms are often used for entity authentication and data
  #    origin authentication with integrity."
  #
  # * keyEncipherment  ==> for plain RSA cipher suites
  #   "The keyEncipherment bit is asserted when the subject public key is used for
  #    key transport. For example, when an RSA key is to be used for key management,
  #    then this bit is set."
  #
  # * keyAgreement     ==> for used with DH, not RSA.
  #   "The keyAgreement bit is asserted when the subject public key is used for key
  #    agreement. For example, when a Diffie-Hellman key is to be used for key
  #    management, then this bit is set."
  #
  # digest options: SHA512, SHA256, SHA1
  #
  def self.server_signing_profile(node)
    {
      "digest" => node.env.provider.ca.server_certificates.digest,
      "extensions" => {
        "keyUsage" => {
          "usage" => ["digitalSignature", "keyEncipherment"]
        },
        "extendedKeyUsage" => {
          "usage" => ["serverAuth", "clientAuth"]
        },
        "subjectAltName" => {
          "ips" => [node.ip_address],
          "dns_names" => node.all_dns_names
        }
      }
    }
  end

  #
  # This is used when signing the main cert for the provider's domain
  # with our own CA (for testing purposes). Typically, this cert would
  # be purchased from a commercial CA, and not signed this way.
  #
  def self.domain_test_signing_profile
    {
      "digest" => "SHA256",
      "extensions" => {
        "keyUsage" => {
          "usage" => ["digitalSignature", "keyEncipherment"]
        },
        "extendedKeyUsage" => {
          "usage" => ["serverAuth"]
        }
      }
    }
  end

  #
  # This is used when signing a dummy client certificate that is only to be
  # used for testing.
  #
  def self.client_test_signing_profile
    {
      "digest" => "SHA256",
      "extensions" => {
        "keyUsage" => {
          "usage" => ["digitalSignature"]
        },
        "extendedKeyUsage" => {
          "usage" => ["clientAuth"]
        }
      }
    }
  end

end; end