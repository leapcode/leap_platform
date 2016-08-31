#
# x509 related methods for Config::Node
#
module LeapCli; module Config

  class Node < Object

    #
    # creates a new server certificate file for this node
    #
    def generate_cert
      require 'leap_cli/x509'

      if self['x509.use'] == false ||
         !Util.file_exists?(:ca_cert, :ca_key) ||
         !self.cert_needs_updating?
        return false
      end

      cert = CertificateAuthority::Certificate.new
      provider = env.provider

      # set subject
      cert.subject.common_name = self.domain.full
      cert.serial_number.number = X509.cert_serial_number(self.domain.full)

      # set expiration
      cert.not_before = X509.yesterday
      cert.not_after  = X509.yesterday_advance(provider.ca.server_certificates.life_span)

      # generate key
      cert.key_material.generate_key(provider.ca.server_certificates.bit_size)

      # sign
      cert.parent = X509.ca_root
      cert.sign!(X509.server_signing_profile(self))

      # save
      Util.write_file!([:node_x509_key, self.name], cert.key_material.private_key.to_pem)
      Util.write_file!([:node_x509_cert, self.name], cert.to_pem)
    end

    #
    # returns true if the certs associated with +node+ need to be regenerated.
    #
    def cert_needs_updating?(log_comments=true)
      require 'leap_cli/x509'

      if log_comments
        def log(*args, &block)
          Util.log(*args, &block)
        end
      else
        def log(*args); end
      end

      node = self
      if !Util.file_exists?([:node_x509_cert, node.name], [:node_x509_key, node.name])
        return true
      else
        cert = X509.load_certificate_file([:node_x509_cert, node.name])
        if !X509.created_by_authority?(cert)
          log :updating, "cert for node '#{node.name}' because it was signed by an old CA root cert."
          return true
        end
        if cert.not_after < Time.now.advance(:months => 2)
          log :updating, "cert for node '#{node.name}' because it will expire soon"
          return true
        end
        if cert.subject.common_name != node.domain.full
          log :updating, "cert for node '#{node.name}' because domain.full has changed (was #{cert.subject.common_name}, now #{node.domain.full})"
          return true
        end
        cert.openssl_body.extensions.each do |ext|
          if ext.oid == "subjectAltName"
            ips = []
            dns_names = []
            ext.value.split(",").each do |value|
              value.strip!
              ips << $1          if value =~ /^IP Address:(.*)$/
              dns_names << $1    if value =~ /^DNS:(.*)$/
            end
            dns_names.sort!
            if ips.first != node.ip_address
              log :updating, "cert for node '#{node.name}' because ip_address has changed (from #{ips.first} to #{node.ip_address})"
              return true
            elsif dns_names != node.all_dns_names
              log :updating, "cert for node '#{node.name}' because domain name aliases have changed" do
                log "from: #{dns_names.inspect}"
                log "to: #{node.all_dns_names.inspect})"
              end
              return true
            end
          end
        end
      end
      return false
    end

    #
    # check the expiration of commercial certs, if any.
    #
    def warn_if_commercial_cert_will_soon_expire
      require 'leap_cli/x509'

      self.all_dns_names.each do |domain|
        if Util.file_exists?([:commercial_cert, domain])
          cert = X509.load_certificate_file([:commercial_cert, domain])
          path = Path.relative_path([:commercial_cert, domain])
          if cert.not_after < Time.now.utc
            Util.log :error, "the commercial certificate '#{path}' has EXPIRED! " +
              "You should renew it with `leap cert renew #{domain}`."
          elsif cert.not_after < Time.now.advance(:months => 2)
            Util.log :warning, "the commercial certificate '#{path}' will expire soon (#{cert.not_after}). "+
              "You should renew it with `leap cert renew #{domain}`."
          end
        end
      end
    end

  end

end; end

