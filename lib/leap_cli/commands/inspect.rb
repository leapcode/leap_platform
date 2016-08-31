module LeapCli; module Commands

  desc 'Prints details about a file. Alternately, the argument FILE can be the name of a node, service or tag.'
  arg_name 'FILE'
  command [:inspect, :i] do |c|
    c.switch 'base', :desc => 'Inspect the FILE from the provider_base (i.e. without local inheritance).', :negatable => false
    c.action do |global_options,options,args|
      object = args.first
      assert! object, 'A file path or node/service/tag name is required'
      method = inspection_method(object)
      if method && defined?(method)
        self.send(method, object, options)
      else
        log "Sorry, I don't know how to inspect that."
      end
    end
  end

  private

  FTYPE_MAP = {
    "PEM certificate"         => :inspect_x509_cert,
    "PEM RSA private key"     => :inspect_x509_key,
    "OpenSSH RSA public key"  => :inspect_ssh_pub_key,
    "PEM certificate request" => :inspect_x509_csr
  }

  SUFFIX_MAP = {
    ".json" => :inspect_unknown_json,
    ".key"  => :inspect_x509_key
  }

  def inspection_method(object)
    if File.exist?(object)
      ftype = `file #{object}`.split(':').last.strip
      suffix = File.extname(object)
      log 2, "file is of type '#{ftype}'"
      if FTYPE_MAP[ftype]
        FTYPE_MAP[ftype]
      elsif SUFFIX_MAP[suffix]
        SUFFIX_MAP[suffix]
      else
        nil
      end
    elsif manager.nodes[object]
      :inspect_node
    elsif manager.services[object]
      :inspect_service
    elsif manager.tags[object]
      :inspect_tag
    elsif object == "common"
      :inspect_common
    elsif object == "provider"
      :inspect_provider
    else
      nil
    end
  end

  #
  # inspectors
  #

  def inspect_x509_key(file_path, options)
    assert_bin! 'openssl'
    puts assert_run! 'openssl rsa -in %s -text -check' % file_path
  end

  def inspect_x509_cert(file_path, options)
    require 'leap_cli/x509'
    assert_bin! 'openssl'
    puts assert_run! 'openssl x509 -in %s -text -noout' % file_path
    log 0, :"SHA1 fingerprint", X509.fingerprint("SHA1", file_path)
    log 0, :"SHA256 fingerprint", X509.fingerprint("SHA256", file_path)
  end

  def inspect_x509_csr(file_path, options)
    assert_bin! 'openssl'
    puts assert_run! 'openssl req -text -noout -verify -in %s' % file_path
  end

  #def inspect_ssh_pub_key(file_path)
  #end

  def inspect_node(arg, options)
    inspect_json manager.nodes[name(arg)]
  end

  def inspect_service(arg, options)
    if options[:base]
      inspect_json manager.base_services[name(arg)]
    else
      inspect_json manager.services[name(arg)]
    end
  end

  def inspect_tag(arg, options)
    if options[:base]
      inspect_json manager.base_tags[name(arg)]
    else
      inspect_json manager.tags[name(arg)]
    end
  end

  def inspect_provider(arg, options)
    if options[:base]
      inspect_json manager.base_provider
    elsif arg =~ /provider\.(.*)\.json/
      inspect_json manager.env($1).provider
    else
      inspect_json manager.provider
    end
  end

  def inspect_common(arg, options)
    if options[:base]
      inspect_json manager.base_common
    else
      inspect_json manager.common
    end
  end

  def inspect_unknown_json(arg, options)
    full_path = File.expand_path(arg, Dir.pwd)
    if path_match?(:node_config, full_path)
      inspect_node(arg, options)
    elsif path_match?(:service_config, full_path)
      inspect_service(arg, options)
    elsif path_match?(:tag_config, full_path)
      inspect_tag(arg, options)
    elsif path_match?(:provider_config, full_path) || path_match?(:provider_env_config, full_path)
      inspect_provider(arg, options)
    elsif path_match?(:common_config, full_path)
      inspect_common(arg, options)
    else
      inspect_json(arg, options)
    end
  end

  #
  # helpers
  #

  def name(arg)
    File.basename(arg).sub(/\.json$/, '')
  end

  def inspect_json(config)
    if config
      puts JSON.sorted_generate(config)
    end
  end

  def path_match?(path_symbol, path)
    Dir.glob(Path.named_path([path_symbol, '*'])).include?(path)
  end

end; end
