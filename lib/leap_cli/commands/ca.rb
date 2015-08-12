autoload :OpenSSL, 'openssl'
autoload :CertificateAuthority, 'certificate_authority'
autoload :Date, 'date'
require 'digest/md5'

module LeapCli; module Commands

  desc "Manage X.509 certificates"
  command :cert do |cert|

    cert.desc 'Creates two Certificate Authorities (one for validating servers and one for validating clients).'
    cert.long_desc 'See see what values are used in the generation of the certificates (like name and key size), run `leap inspect provider` and look for the "ca" property. To see the details of the created certs, run `leap inspect <file>`.'
    cert.command :ca do |ca|
      ca.action do |global_options,options,args|
        assert_config! 'provider.ca.name'
        generate_new_certificate_authority(:ca_key, :ca_cert, provider.ca.name)
        generate_new_certificate_authority(:client_ca_key, :client_ca_cert, provider.ca.name + ' (client certificates only!)')
      end
    end

    cert.desc 'Creates or renews a X.509 certificate/key pair for a single node or all nodes, but only if needed.'
    cert.long_desc 'This command will a generate new certificate for a node if some value in the node has changed ' +
                   'that is included in the certificate (like hostname or IP address), or if the old certificate will be expiring soon. ' +
                   'Sometimes, you might want to force the generation of a new certificate, ' +
                   'such as in the cases where you have changed a CA parameter for server certificates, like bit size or digest hash. ' +
                   'In this case, use --force. If <node-filter> is empty, this command will apply to all nodes.'
    cert.arg_name 'FILTER'
    cert.command :update do |update|
      update.switch 'force', :desc => 'Always generate new certificates', :negatable => false
      update.action do |global_options,options,args|
        update_certificates(manager.filter!(args), options)
      end
    end

    cert.desc 'Creates a Diffie-Hellman parameter file, needed for forward secret OpenVPN ciphers.' # (needed for server-side of some TLS connections)
    cert.command :dh do |dh|
      dh.action do |global_options,options,args|
        long_running do
          if cmd_exists?('certtool')
            log 0, 'Generating DH parameters (takes a long time)...'
            output = assert_run!('certtool --generate-dh-params --sec-param high')
            output.sub! /.*(-----BEGIN DH PARAMETERS-----.*-----END DH PARAMETERS-----).*/m, '\1'
            output << "\n"
            write_file!(:dh_params, output)
          else
            log 0, 'Generating DH parameters (takes a REALLY long time)...'
            output = OpenSSL::PKey::DH.generate(3248).to_pem
            write_file!(:dh_params, output)
          end
        end
      end
    end

    #
    # hints:
    #
    # inspect CSR:
    #   openssl req -noout -text -in files/cert/x.csr
    #
    # generate CSR with openssl to see how it compares:
    #   openssl req -sha256 -nodes -newkey rsa:2048 -keyout example.key -out example.csr
    #
    # validate a CSR:
    #   http://certlogik.com/decoder/
    #
    # nice details about CSRs:
    #   http://www.redkestrel.co.uk/Articles/CSR.html
    #
    cert.desc "Creates a CSR for use in buying a commercial X.509 certificate."
    cert.long_desc "Unless specified, the CSR is created for the provider's primary domain. "+
      "The properties used for this CSR come from `provider.ca.server_certificates`, "+
      "but may be overridden here."
    cert.command :csr do |csr|
      csr.flag 'domain', :arg_name => 'DOMAIN', :desc => 'Specify what domain to create the CSR for.'
      csr.flag ['organization', 'O'], :arg_name => 'ORGANIZATION', :desc => "Override default O in distinguished name."
      csr.flag ['unit', 'OU'], :arg_name => 'UNIT', :desc => "Set OU in distinguished name."
      csr.flag 'email', :arg_name => 'EMAIL', :desc => "Set emailAddress in distinguished name."
      csr.flag ['locality', 'L'], :arg_name => 'LOCALITY', :desc => "Set L in distinguished name."
      csr.flag ['state', 'ST'], :arg_name => 'STATE', :desc => "Set ST in distinguished name."
      csr.flag ['country', 'C'], :arg_name => 'COUNTRY', :desc => "Set C in distinguished name."
      csr.flag :bits, :arg_name => 'BITS', :desc => "Override default certificate bit length"
      csr.flag :digest, :arg_name => 'DIGEST', :desc => "Override default signature digest"
      csr.action do |global_options,options,args|
        assert_config! 'provider.domain'
        assert_config! 'provider.name'
        assert_config! 'provider.default_language'
        assert_config! 'provider.ca.server_certificates.bit_size'
        assert_config! 'provider.ca.server_certificates.digest'
        domain = options[:domain] || provider.domain

        unless global_options[:force]
          assert_files_missing! [:commercial_key, domain], [:commercial_csr, domain],
            :msg => 'If you really want to create a new key and CSR, remove these files first or run with --force.'
        end

        server_certificates = provider.ca.server_certificates

        # RSA key
        keypair = CertificateAuthority::MemoryKeyMaterial.new
        bit_size = (options[:bits] || server_certificates.bit_size).to_i
        log :generating, "%s bit RSA key" % bit_size do
          keypair.generate_key(bit_size)
          write_file! [:commercial_key, domain], keypair.private_key.to_pem
        end

        # CSR
        dn  = CertificateAuthority::DistinguishedName.new
        dn.common_name   = domain
        dn.organization  = options[:organization] || provider.name[provider.default_language]
        dn.ou            = options[:organizational_unit] # optional
        dn.email_address = options[:email] # optional
        dn.country       = options[:country] || server_certificates['country']   # optional
        dn.state         = options[:state] || server_certificates['state']       # optional
        dn.locality      = options[:locality] || server_certificates['locality'] # optional

        digest = options[:digest] || server_certificates.digest
        log :generating, "CSR with #{digest} digest and #{print_dn(dn)}" do
          csr = create_csr(dn, keypair, digest)
          request = csr.to_x509_csr
          write_file! [:commercial_csr, domain], csr.to_pem
        end

        # Sign using our own CA, for use in testing but hopefully not production.
        # It is not that commerical CAs are so secure, it is just that signing your own certs is
        # a total drag for the user because they must click through dire warnings.
        #if options[:sign]
          log :generating, "self-signed x509 server certificate for testing purposes" do
            cert = csr.to_cert
            cert.serial_number.number = cert_serial_number(domain)
            cert.not_before = yesterday
            cert.not_after  = yesterday.advance(:years => 1)
            cert.parent = ca_root
            cert.sign! domain_test_signing_profile
            write_file! [:commercial_cert, domain], cert.to_pem
            log "please replace this file with the real certificate you get from a CA using #{Path.relative_path([:commercial_csr, domain])}"
          end
        #end

        # FAKE CA
        unless file_exists? :commercial_ca_cert
          log :using, "generated CA in place of commercial CA for testing purposes" do
            write_file! :commercial_ca_cert, read_file!(:ca_cert)
            log "please also replace this file with the CA cert from the commercial authority you use."
          end
        end
      end
    end
  end

  protected

  #
  # will generate new certificates for the specified nodes, if needed.
  #
  def update_certificates(nodes, options={})
    assert_files_exist! :ca_cert, :ca_key, :msg => 'Run `leap cert ca` to create them'
    assert_config! 'provider.ca.server_certificates.bit_size'
    assert_config! 'provider.ca.server_certificates.digest'
    assert_config! 'provider.ca.server_certificates.life_span'
    assert_config! 'common.x509.use'

    nodes.each_node do |node|
      warn_if_commercial_cert_will_soon_expire(node)
      if !node.x509.use
        remove_file!([:node_x509_key, node.name])
        remove_file!([:node_x509_cert, node.name])
      elsif options[:force] || cert_needs_updating?(node)
        generate_cert_for_node(node)
      end
    end
  end

  private

  def generate_new_certificate_authority(key_file, cert_file, common_name)
    assert_files_missing! key_file, cert_file
    assert_config! 'provider.ca.name'
    assert_config! 'provider.ca.bit_size'
    assert_config! 'provider.ca.life_span'

    root = CertificateAuthority::Certificate.new

    # set subject
    root.subject.common_name = common_name
    possible = ['country', 'state', 'locality', 'organization', 'organizational_unit', 'email_address']
    provider.ca.keys.each do |key|
      if possible.include?(key)
        root.subject.send(key + '=', provider.ca[key])
      end
    end

    # set expiration
    root.not_before = yesterday
    root.not_after = yesterday_advance(provider.ca.life_span)

    # generate private key
    root.serial_number.number = 1
    root.key_material.generate_key(provider.ca.bit_size)

    # sign self
    root.signing_entity = true
    root.parent = root
    root.sign!(ca_root_signing_profile)

    # save
    write_file!(key_file, root.key_material.private_key.to_pem)
    write_file!(cert_file, root.to_pem)
  end

  #
  # returns true if the certs associated with +node+ need to be regenerated.
  #
  def cert_needs_updating?(node)
    if !file_exists?([:node_x509_cert, node.name], [:node_x509_key, node.name])
      return true
    else
      cert = load_certificate_file([:node_x509_cert, node.name])
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
          elsif dns_names != dns_names_for_node(node)
            log :updating, "cert for node '#{node.name}' because domain name aliases have changed\n    from: #{dns_names.inspect}\n    to: #{dns_names_for_node(node).inspect})"
            return true
          end
        end
      end
    end
    return false
  end

  def warn_if_commercial_cert_will_soon_expire(node)
    dns_names_for_node(node).each do |domain|
      if file_exists?([:commercial_cert, domain])
        cert = load_certificate_file([:commercial_cert, domain])
        path = Path.relative_path([:commercial_cert, domain])
        if cert.not_after < Time.now.utc
          log :error, "the commercial certificate '#{path}' has EXPIRED! " +
            "You should renew it with `leap cert csr --domain #{domain}`."
        elsif cert.not_after < Time.now.advance(:months => 2)
          log :warning, "the commercial certificate '#{path}' will expire soon. "+
            "You should renew it with `leap cert csr --domain #{domain}`."
        end
      end
    end
  end

  def generate_cert_for_node(node)
    return if node.x509.use == false

    cert = CertificateAuthority::Certificate.new

    # set subject
    cert.subject.common_name = node.domain.full
    cert.serial_number.number = cert_serial_number(node.domain.full)

    # set expiration
    cert.not_before = yesterday
    cert.not_after = yesterday_advance(provider.ca.server_certificates.life_span)

    # generate key
    cert.key_material.generate_key(provider.ca.server_certificates.bit_size)

    # sign
    cert.parent = ca_root
    cert.sign!(server_signing_profile(node))

    # save
    write_file!([:node_x509_key, node.name], cert.key_material.private_key.to_pem)
    write_file!([:node_x509_cert, node.name], cert.to_pem)
  end

  #
  # yields client key and cert suitable for testing
  #
  def generate_test_client_cert(prefix=nil)
    cert = CertificateAuthority::Certificate.new
    cert.serial_number.number = cert_serial_number(provider.domain)
    cert.subject.common_name = [prefix, random_common_name(provider.domain)].join
    cert.not_before = yesterday
    cert.not_after  = yesterday.advance(:years => 1)
    cert.key_material.generate_key(1024) # just for testing, remember!
    cert.parent = client_ca_root
    cert.sign! client_test_signing_profile
    yield cert.key_material.private_key.to_pem, cert.to_pem
  end

  #
  # creates a CSR and returns it.
  # with the correct extReq attribute so that the CA
  # doens't generate certs with extensions we don't want.
  #
  def create_csr(dn, keypair, digest)
    csr = CertificateAuthority::SigningRequest.new
    csr.distinguished_name = dn
    csr.key_material = keypair
    csr.digest = digest

    # define extensions manually (library doesn't support setting these on CSRs)
    extensions = []
    extensions << CertificateAuthority::Extensions::BasicConstraints.new.tap {|basic|
      basic.ca = false
    }
    extensions << CertificateAuthority::Extensions::KeyUsage.new.tap {|keyusage|
      keyusage.usage = ["digitalSignature", "keyEncipherment"]
    }
    extensions << CertificateAuthority::Extensions::ExtendedKeyUsage.new.tap {|extkeyusage|
      extkeyusage.usage = [ "serverAuth"]
    }

    # convert extensions to attribute 'extReq'
    # aka "Requested Extensions"
    factory = OpenSSL::X509::ExtensionFactory.new
    attrval = OpenSSL::ASN1::Set([OpenSSL::ASN1::Sequence(
      extensions.map{|e| factory.create_ext(e.openssl_identifier, e.to_s, e.critical)}
    )])
    attrs = [
      OpenSSL::X509::Attribute.new("extReq", attrval),
    ]
    csr.attributes = attrs

    return csr
  end

  def ca_root
    @ca_root ||= begin
      load_certificate_file(:ca_cert, :ca_key)
    end
  end

  def client_ca_root
    @client_ca_root ||= begin
      load_certificate_file(:client_ca_cert, :client_ca_key)
    end
  end

  def load_certificate_file(crt_file, key_file=nil, password=nil)
    crt = read_file!(crt_file)
    openssl_cert = OpenSSL::X509::Certificate.new(crt)
    cert = CertificateAuthority::Certificate.from_openssl(openssl_cert)
    if key_file
      key = read_file!(key_file)
      cert.key_material.private_key = OpenSSL::PKey::RSA.new(key, password)
    end
    return cert
  end

  def ca_root_signing_profile
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
  def server_signing_profile(node)
    {
      "digest" => provider.ca.server_certificates.digest,
      "extensions" => {
        "keyUsage" => {
          "usage" => ["digitalSignature", "keyEncipherment"]
        },
        "extendedKeyUsage" => {
          "usage" => ["serverAuth", "clientAuth"]
        },
        "subjectAltName" => {
          "ips" => [node.ip_address],
          "dns_names" => dns_names_for_node(node)
        }
      }
    }
  end

  #
  # This is used when signing the main cert for the provider's domain
  # with our own CA (for testing purposes). Typically, this cert would
  # be purchased from a commercial CA, and not signed this way.
  #
  def domain_test_signing_profile
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
  def client_test_signing_profile
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

  def dns_names_for_node(node)
    names = [node.domain.internal, node.domain.full]
    if node['dns'] && node.dns['aliases'] && node.dns.aliases.any?
      names += node.dns.aliases
    end
    names.compact!
    names.sort!
    names.uniq!
    return names
  end

  #
  # For cert serial numbers, we need a non-colliding number less than 160 bits.
  # md5 will do nicely, since there is no need for a secure hash, just a short one.
  # (md5 is 128 bits)
  #
  def cert_serial_number(domain_name)
    Digest::MD5.hexdigest("#{domain_name} -- #{Time.now}").to_i(16)
  end

  #
  # for the random common name, we need a text string that will be unique across all certs.
  # ruby 1.8 doesn't have a built-in uuid generator, or we would use SecureRandom.uuid
  #
  def random_common_name(domain_name)
    cert_serial_number(domain_name).to_s(36)
  end

  # prints CertificateAuthority::DistinguishedName fields
  def print_dn(dn)
    fields = {}
    [:common_name, :locality, :state, :country, :organization, :organizational_unit, :email_address].each do |attr|
      fields[attr] = dn.send(attr) if dn.send(attr)
    end
    fields.inspect
  end

  ##
  ## TIME HELPERS
  ##
  ## note: we use 'yesterday' instead of 'today', because times are in UTC, and some people on the planet
  ## are behind UTC.
  ##

  def yesterday
    t = Time.now - 24*24*60
    Time.utc t.year, t.month, t.day
  end

  def yesterday_advance(string)
    number, unit = string.split(' ')
    unless ['years', 'months', 'days', 'hours', 'minutes'].include? unit
      bail!("The time property '#{string}' is missing a unit (one of: years, months, days, hours, minutes).")
    end
    unless number.to_i.to_s == number
      bail!("The time property '#{string}' is missing a number.")
    end
    yesterday.advance(unit.to_sym => number.to_i)
  end

end; end
