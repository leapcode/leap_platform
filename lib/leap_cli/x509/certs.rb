
module LeapCli; module X509

  #
  # returns a fingerprint of a x509 certificate
  #
  # Note: there are different ways of computing a digest of a certificate.
  # You can either take a digest of the entire cert in DER format, or you
  # can take a digest of the public key.
  #
  # For now, we only support the DER method.
  #
  def self.fingerprint(digest, cert_file)
    if cert_file.is_a? String
      cert = OpenSSL::X509::Certificate.new(Util.read_file!(cert_file))
    elsif cert_file.is_a? OpenSSL::X509::Certificate
      cert = cert_file
    elsif cert_file.is_a? CertificateAuthority::Certificate
      cert = cert_file.openssl_body
    end
    digester = case digest
      when "MD5" then Digest::MD5.new
      when "SHA1" then Digest::SHA1.new
      when "SHA256" then Digest::SHA256.new
      when "SHA384" then Digest::SHA384.new
      when "SHA512" then Digest::SHA512.new
    end
    digester.hexdigest(cert.to_der)
  end

  def self.ca_root
    @ca_root ||= begin
      load_certificate_file(:ca_cert, :ca_key)
    end
  end

  def self.client_ca_root
    @client_ca_root ||= begin
      load_certificate_file(:client_ca_cert, :client_ca_key)
    end
  end

  def self.load_certificate_file(crt_file, key_file=nil, password=nil)
    crt = Util.read_file!(crt_file)
    openssl_cert = OpenSSL::X509::Certificate.new(crt)
    cert = CertificateAuthority::Certificate.from_openssl(openssl_cert)
    if key_file
      key = Util.read_file!(key_file)
      cert.key_material.private_key = OpenSSL::PKey::RSA.new(key, password)
    end
    return cert
  end

  #
  # creates a new certificate authority.
  #
  def self.new_ca(options, common_name)
    root = CertificateAuthority::Certificate.new

    # set subject
    root.subject.common_name = common_name
    possible = ['country', 'state', 'locality', 'organization', 'organizational_unit', 'email_address']
    options.keys.each do |key|
      if possible.include?(key)
        root.subject.send(key + '=', options[key])
      end
    end

    # set expiration
    root.not_before = X509.yesterday
    root.not_after = X509.yesterday_advance(options['life_span'])

    # generate private key
    root.serial_number.number = 1
    root.key_material.generate_key(options['bit_size'])

    # sign self
    root.signing_entity = true
    root.parent = root
    root.sign!(ca_root_signing_profile)
    return root
  end

  #
  # creates a CSR in memory and returns it.
  # with the correct extReq attribute so that the CA
  # doens't generate certs with extensions we don't want.
  #
  def self.new_csr(dn, keypair, digest)
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

  #
  # creates new csr and cert files for a particular domain.
  #
  # The cert is signed with the ca_root, but should be replaced
  # later with a real cert signed by a better ca
  #
  def self.create_csr_and_cert(options)
    bit_size = options[:bits].to_i
    digest   = options[:digest]

    # RSA key
    keypair = CertificateAuthority::MemoryKeyMaterial.new
    Util.log :generating, "%s bit RSA key" % bit_size do
      keypair.generate_key(bit_size)
      Util.write_file! [:commercial_key, options[:domain]], keypair.private_key.to_pem
    end

    # CSR
    csr = nil
    dn  = CertificateAuthority::DistinguishedName.new
    dn.common_name   = options[:domain]
    dn.organization  = options[:organization]
    dn.ou            = options[:organizational_unit]
    dn.email_address = options[:email]
    dn.country       = options[:country]
    dn.state         = options[:state]
    dn.locality      = options[:locality]
    Util.log :generating, "CSR with #{digest} digest and #{print_dn(dn)}" do
      csr = new_csr(dn, keypair, options[:digest])
      Util.write_file! [:commercial_csr, options[:domain]], csr.to_pem
    end

    # Sign using our own CA, for use in testing but hopefully not production.
    # It is not that commerical CAs are so secure, it is just that signing your own certs is
    # a total drag for the user because they must click through dire warnings.
    Util.log :generating, "self-signed x509 server certificate for testing purposes" do
      cert = csr.to_cert
      cert.serial_number.number = cert_serial_number(options[:domain])
      cert.not_before = yesterday
      cert.not_after  = yesterday.advance(:years => 1)
      cert.parent = ca_root
      cert.sign! domain_test_signing_profile
      Util.write_file! [:commercial_cert, options[:domain]], cert.to_pem
      Util.log "please replace this file with the real certificate you get from a CA using #{Path.relative_path([:commercial_csr, options[:domain]])}"
    end

    # Fake CA
    unless Util.file_exists? :commercial_ca_cert
      Util.log :using, "generated CA in place of commercial CA for testing purposes" do
        Util.write_file! :commercial_ca_cert, Util.read_file!(:ca_cert)
        Util.log "please also replace this file with the CA cert from the commercial authority you use."
      end
    end
  end

  #
  # Return true if the given server cert has been signed by the given CA cert
  #
  # This does not actually validate the signature, it just checks the cert
  # extensions.
  #
  def self.created_by_authority?(cert, ca=X509.ca_root)
    authority_key_id = cert.extensions["authorityKeyIdentifier"].identifier.sub(/^keyid:/, '')
    return authority_key_id == self.public_key_id_for_ca(ca)
  end

  #
  # For cert serial numbers, we need a non-colliding number less than 160 bits.
  # md5 will do nicely, since there is no need for a secure hash, just a short one.
  # (md5 is 128 bits)
  #
  def self.cert_serial_number(domain_name)
    Digest::MD5.hexdigest("#{domain_name} -- #{Time.now}").to_i(16)
  end

  #
  # for the random common name, we need a text string that will be
  # unique across all certs.
  #
  def self.random_common_name(domain_name)
    #cert_serial_number(domain_name).to_s(36)
    SecureRandom.uuid
  end

  private

  #
  # calculate the "key id" for a root CA, that matches the value
  # Authority Key Identifier in the x509 extensions of a cert.
  #
  def self.public_key_id_for_ca(ca_cert)
    @ca_key_ids ||= {}
    @ca_key_ids[ca_cert.object_id] ||= begin
      pubkey = ca_cert.key_material.public_key
      seq = OpenSSL::ASN1::Sequence([
        OpenSSL::ASN1::Integer.new(pubkey.n),
        OpenSSL::ASN1::Integer.new(pubkey.e)
      ])
      Digest::SHA1.hexdigest(seq.to_der).upcase.scan(/../).join(':')
    end
  end

  # prints CertificateAuthority::DistinguishedName fields
  def self.print_dn(dn)
    fields = {}
    [:common_name, :locality, :state, :country, :organization, :organizational_unit, :email_address].each do |attr|
      fields[attr] = dn.send(attr) if dn.send(attr)
    end
    fields.inspect
  end

end; end
