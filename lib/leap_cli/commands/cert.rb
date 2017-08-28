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
        generate_dh
      end
    end

    cert.desc "Creates a CSR for use in buying a commercial X.509 certificate."
    cert.long_desc "Unless specified, the CSR is created for the provider's primary domain. "+
      "The properties used for this CSR come from `provider.ca.server_certificates`, "+
      "but may be overridden here."
    cert.arg_name "DOMAIN"
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
        generate_csr(global_options, options, args)
      end
    end

    cert.desc "Register an authorization key with the CA letsencrypt.org"
    cert.long_desc "This only needs to be done once."
    cert.command :register do |register|
      register.action do |global, options, args|
        do_register_key(global, options, args)
      end
    end

    cert.desc "Renews a certificate using the CA letsencrypt.org"
    cert.arg_name "DOMAIN"
    cert.command :renew do |renew|
      renew.action do |global, options, args|
        do_renew_cert(global, options, args)
      end
    end

  end

  protected

  #
  # will generate new certificates for the specified nodes, if needed.
  #
  def update_certificates(nodes, options={})
    require 'leap_cli/x509'
    assert_files_exist! :ca_cert, :ca_key, :msg => 'Run `leap cert ca` to create them'
    assert_config! 'provider.ca.server_certificates.bit_size'
    assert_config! 'provider.ca.server_certificates.digest'
    assert_config! 'provider.ca.server_certificates.life_span'
    assert_config! 'common.x509.use'

    nodes.each_node do |node|
      node.warn_if_commercial_cert_will_soon_expire
      if !node.x509.use
        remove_file!([:node_x509_key, node.name])
        remove_file!([:node_x509_cert, node.name])
      elsif options[:force] || node.cert_needs_updating?
        node.generate_cert
      end
    end
  end

  #
  # yields client key and cert suitable for testing
  #
  def generate_test_client_cert(prefix=nil)
    require 'leap_cli/x509'
    cert = CertificateAuthority::Certificate.new
    cert.serial_number.number = X509.cert_serial_number(provider.domain)
    cert.subject.common_name = [prefix, X509.random_common_name(provider.domain)].join
    cert.not_before = X509.yesterday
    cert.not_after  = X509.yesterday.advance(:years => 1)
    cert.key_material.generate_key(1024) # just for testing, remember!
    cert.parent = X509.client_ca_root
    cert.sign! X509.client_test_signing_profile
    yield cert.key_material.private_key.to_pem, cert.to_pem
  end

  private

  def generate_new_certificate_authority(key_file, cert_file, common_name)
    require 'leap_cli/x509'
    assert_files_missing! key_file, cert_file
    assert_config! 'provider.ca.name'
    assert_config! 'provider.ca.bit_size'
    assert_config! 'provider.ca.life_span'

    root = X509.new_ca(provider.ca, common_name)

    write_file!(key_file, root.key_material.private_key.to_pem)
    write_file!(cert_file, root.to_pem)
  end

  def generate_dh
    require 'leap_cli/x509'
    long_running do
      if cmd_exists?('certtool')
        log 0, 'Generating DH parameters (takes a long time)...'
        output = assert_run!('certtool --generate-dh-params --sec-param high')
        output.sub!(/.*(-----BEGIN DH PARAMETERS-----.*-----END DH PARAMETERS-----).*/m, '\1')
        output << "\n"
        write_file!(:dh_params, output)
      else
        log 0, 'Generating DH parameters (takes a REALLY long time)...'
        output = OpenSSL::PKey::DH.generate(3248).to_pem
        write_file!(:dh_params, output)
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
  def generate_csr(global_options, options, args)
    require 'leap_cli/x509'
    assert_config! 'provider.domain'
    assert_config! 'provider.name'
    assert_config! 'provider.default_language'
    assert_config! 'provider.ca.server_certificates.bit_size'
    assert_config! 'provider.ca.server_certificates.digest'

    server_certificates      = provider.ca.server_certificates
    options[:domain]       ||= args.first || provider.domain
    options[:organization] ||= provider.name[provider.default_language]
    options[:country]      ||= server_certificates['country']
    options[:state]        ||= server_certificates['state']
    options[:locality]     ||= server_certificates['locality']
    options[:bits]         ||= server_certificates.bit_size
    options[:digest]       ||= server_certificates.digest

    unless global_options[:force]
      assert_files_missing! [:commercial_key, options[:domain]], [:commercial_csr, options[:domain]],
        :msg => 'If you really want to create a new key and CSR, remove these files first or run with --force.'
    end

    X509.create_csr_and_cert(options)
  end

  #
  # letsencrypt.org
  #

  def do_register_key(global, options, args)
    require 'leap_cli/acme'
    assert_config! 'provider.contacts.default'
    contact = manager.provider.contacts.default.first

    if file_exists?(:acme_key) && !global[:force]
      bail! do
        log "the authorization key for letsencrypt.org already exists"
        log "run with --force if you really want to register a new key."
      end
    else
      private_key = Acme.new_private_key
      registration = nil

      log(:registering, "letsencrypt.org authorization key using contact `%s`" % contact) do
        acme = Acme.new(key: private_key)
        registration = acme.register(contact)
        if registration
          log 'success!', :color => :green, :style => :bold
        else
          bail! "could not register authorization key."
        end
      end

      log :saving, "authorization key for letsencrypt.org" do
        write_file!(:acme_key, private_key.to_pem)
        write_file!(:acme_info, JSON.sorted_generate({
          id: registration.id,
          contact: registration.contact,
          key: registration.key,
          uri: registration.uri
        }))
        log :warning, "keep key file private!"
      end
    end
  end

  def assert_no_errors!(msg)
    yield
  rescue StandardError => exc
    bail! :error, msg do
      log exc.to_s
    end
  end

  def do_renew_cert(global, options, args)
    require 'leap_cli/acme'
    require 'leap_cli/ssh'
    require 'socket'
    require 'net/http'

    csr = nil
    account_key = nil
    cert = nil
    acme = nil

    #
    # sanity check the domain
    #
    domain = args.first
    nodes  = nodes_for_domain(domain)
    domain_ready_for_acme!(domain)

    #
    # load key material
    #
    assert_files_exist!([:commercial_key, domain], [:commercial_csr, domain],
      :msg => 'Please create the CSR first with `leap cert csr %s`' % domain)
    assert_no_errors!("Could not load #{path([:commercial_csr, domain])}") do
      csr = Acme.load_csr(read_file!([:commercial_csr, domain]))
    end
    assert_files_exist!(:acme_key,
      :msg => "Please run `leap cert register` first. This only needs to be done once.")
    assert_no_errors!("Could not load #{path(:acme_key)}") do
      account_key = Acme.load_private_key(read_file!(:acme_key))
    end

    #
    # check authorization for this domain
    #
    log :checking, "authorization"
    acme = Acme.new(domain: domain, key: account_key)
    status, message = acme.authorize do |challenge|
      log(:uploading, 'challenge to server %s' % domain) do
        SSH.remote_command(nodes) do |ssh, host|
          ssh.scripts.upload_acme_challenge(challenge.token, challenge.file_content)
        end
      end
      log :waiting, "for letsencrypt.org to verify challenge"
    end
    if status == 'valid'
      log 'authorized!', color: :green, style: :bold
    elsif status == 'error'
      bail! :error, message.inspect
    elsif status == 'unauthorized'
      bail!(:unauthorized, message.inspect, color: :yellow, style: :bold) do
        log 'You must first run `leap cert register` to register the account key with letsencrypt.org'
      end
    else
      bail!(:error, "unrecognized status: #{status.inspect}, #{message.inspect}")
    end

    log :fetching, "new certificate from letsencrypt.org"
    assert_no_errors!("could not renew certificate") do
      cert = acme.get_certificate(csr)
    end
    log 'success', color: :green, style: :bold
    write_file!([:commercial_cert, domain], cert.fullchain_to_pem)
    log 'You should now run `leap deploy` to deploy the new certificate.'
  end

  #
  # Returns a hash of nodes that match this domain. It also checks:
  #
  # * a node configuration has this domain
  # * the dns for the domain exists
  #
  # This method will bail if any checks fail.
  #
  def nodes_for_domain(domain)
    bail! { log 'Argument DOMAIN is required' } if domain.nil? || domain.empty?
    nodes = manager.nodes['dns.aliases' => domain]
    if nodes.empty?
      bail! :error, "There are no nodes configured for domain `%s`" % domain
    end
    begin
      ips = Socket.getaddrinfo(domain, 'http').map {|record| record[2]}.uniq
      nodes = nodes['ip_address' => ips]
      if nodes.empty?
        bail! do
          log :error, "The domain `%s` resolves to [%s]" % [domain, ips.join(', ')]
          log :error, "But there no nodes configured for this domain with these adddresses."
        end
      end
    rescue SocketError
      bail! :error, "Could not resolve the DNS for `#{domain}`. Without a DNS " +
        "entry for this domain, authorization will not work."
    end
    return nodes
  end

  #
  # runs the following checks on the domain:
  #
  # * we are able to get /.well-known/acme-challenge/ok
  #
  # This method will bail if any checks fail.
  #
  def domain_ready_for_acme!(domain)
    uri = URI("https://#{domain}/.well-known/acme-challenge/ok")
    options = {
      use_ssl: true,
      open_timeout: 5,
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
    http_get(uri, options)
  end

  private

  def http_get(uri, options, limit = 10)
    raise ArgumentError, "HTTP redirect too deep (#{uri})" if limit == 0
    Net::HTTP.start(uri.host, uri.port, options) do |http|
      http.request(Net::HTTP::Get.new(uri)) do |response|
        case response
        when Net::HTTPSuccess then
          return response
        when Net::HTTPRedirection then
          return http_get(URI(response['location']), options, limit - 1)
        else
          bail!(:error, "Could not GET %s" % uri) do
            log "%s %s" % [response.code, response.message]
            log "You may need to run `leap deploy`"
          end
        end
      end
    end
  rescue Errno::ETIMEDOUT, Net::OpenTimeout
    bail! :error, "Connection attempt timed out: %s" % uri
  rescue Interrupt
    bail!
  rescue StandardError => exc
    bail!(:error, "Could not GET %s" % uri) do
      log exc.to_s
    end
  end

end; end
