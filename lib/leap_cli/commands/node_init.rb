#
# Node initialization.
# Most of the fun stuff is in tasks.rb.
#

module LeapCli; module Commands

  desc 'Node management'
  command :node do |cmd|
    cmd.desc 'Bootstraps a node or nodes, setting up SSH keys and installing prerequisite packages'
    cmd.long_desc "This command prepares a server to be used with the LEAP Platform by saving the server's SSH host key, " +
                   "copying the authorized_keys file, installing packages that are required for deploying, and registering important facts. " +
                   "Node init must be run before deploying to a server, and the server must be running and available via the network. " +
                   "This command only needs to be run once, but there is no harm in running it multiple times."
    cmd.arg_name 'FILTER'
    cmd.command :init do |init|
      init.switch 'echo', :desc => 'If set, passwords are visible as you type them (default is hidden)', :negatable => false
      init.flag :port, :desc => 'Override the default SSH port.', :arg_name => 'PORT'
      init.flag :ip,   :desc => 'Override the default SSH IP address.', :arg_name => 'IPADDRESS'

      init.action do |global,options,args|
        assert! args.any?, 'You must specify a FILTER'
        finished = []
        manager.filter!(args).each_node do |node|
          is_node_alive(node, options)
          save_public_host_key(node, global, options) unless node.vagrant?
          update_compiled_ssh_configs
          ssh_connect_options = connect_options(options).merge({:bootstrap => true, :echo => options[:echo]})
          ssh_connect(node, ssh_connect_options) do |ssh|
            if node.vagrant?
              ssh.install_insecure_vagrant_key
            end
            ssh.install_authorized_keys
            ssh.install_prerequisites
            unless node.vagrant?
              ssh.leap.log(:checking, "SSH host keys") do
                ssh.leap.capture(get_ssh_keys_cmd) do |response|
                  update_local_ssh_host_keys(node, response[:data]) if response[:exitcode] == 0
                end
              end
            end
            ssh.leap.log(:updating, "facts") do
              ssh.leap.capture(facter_cmd) do |response|
                if response[:exitcode] == 0
                  update_node_facts(node.name, response[:data])
                else
                  log :failed, "to run facter on #{node.name}"
                end
              end
            end
          end
          finished << node.name
        end
        log :completed, "initialization of nodes #{finished.join(', ')}"
      end
    end
  end

  private

  ##
  ## PRIVATE HELPERS
  ##

  def is_node_alive(node, options)
    address = options[:ip] || node.ip_address
    port = options[:port] || node.ssh.port
    log :connecting, "to node #{node.name}"
    assert_run! "nc -zw3 #{address} #{port}",
      "Failed to reach #{node.name} (address #{address}, port #{port}). You can override the configured IP address and port with --ip or --port."
  end

  #
  # saves the public ssh host key for node into the provider directory.
  #
  # see `man sshd` for the format of known_hosts
  #
  def save_public_host_key(node, global, options)
    log :fetching, "public SSH host key for #{node.name}"
    address = options[:ip] || node.ip_address
    port = options[:port] || node.ssh.port
    host_keys = get_public_keys_for_ip(address, port)
    pub_key_path = Path.named_path([:node_ssh_pub_key, node.name])

    if Path.exists?(pub_key_path)
      if host_keys.include? SshKey.load(pub_key_path)
        log :trusted, "- Public SSH host key for #{node.name} matches previously saved key", :indent => 1
      else
        bail! do
          log :error, "The public SSH host keys we just fetched for #{node.name} doesn't match what we have saved previously.", :indent => 1
          log "Delete the file #{pub_key_path} if you really want to remove the trusted SSH host key.", :indent => 2
        end
      end
    else
      known_key = host_keys.detect{|k|k.in_known_hosts?(node.name, node.ip_address, node.domain.name)}
      if known_key
        log :trusted, "- Public SSH host key for #{node.name} is trusted (key found in your ~/.ssh/known_hosts)"
      else
        public_key = SshKey.pick_best_key(host_keys)
        if public_key.nil?
          bail!("We got back #{host_keys.size} host keys from #{node.name}, but we can't support any of them.")
        else
          say("   This is the SSH host key you got back from node \"#{node.name}\"")
          say("   Type        -- #{public_key.bits} bit #{public_key.type.upcase}")
          say("   Fingerprint -- " + public_key.fingerprint)
          say("   Public Key  -- " + public_key.key)
          if !global[:yes] && !agree("   Is this correct? ")
            bail!
          else
            known_key = public_key
          end
        end
      end
      puts
      write_file! [:node_ssh_pub_key, node.name], known_key.to_s
    end
  end

  #
  # Get the public host keys for a host using ssh-keyscan.
  # Return an array of SshKey objects, one for each key.
  #
  def get_public_keys_for_ip(address, port=22)
    assert_bin!('ssh-keyscan')
    output = assert_run! "ssh-keyscan -p #{port} #{address}", "Could not get the public host key from #{address}:#{port}. Maybe sshd is not running?"
    if output.empty?
      bail! :failed, "ssh-keyscan returned empty output."
    end

    if output =~ /No route to host/
      bail! :failed, 'ssh-keyscan: no route to %s' % address
    else
      keys = SshKey.parse_keys(output)
      if keys.empty?
        bail! "ssh-keyscan got zero host keys back (that we understand)! Output was: #{output}"
      else
        return keys
      end
    end
  end

  # run on the server to generate a string suitable for passing to SshKey.parse_keys()
  def get_ssh_keys_cmd
    "/bin/grep ^HostKey /etc/ssh/sshd_config | /usr/bin/awk '{print $2 \".pub\"}' | /usr/bin/xargs /bin/cat"
  end

  #
  # Sometimes the ssh host keys on the server will be better than what we have
  # stored locally. In these cases, ask the user if they want to upgrade.
  #
  def update_local_ssh_host_keys(node, remote_keys_string)
    remote_keys = SshKey.parse_keys(remote_keys_string)
    return unless remote_keys.any?
    current_key = SshKey.load(Path.named_path([:node_ssh_pub_key, node.name]))
    best_key = SshKey.pick_best_key(remote_keys)
    return unless best_key && current_key
    if current_key != best_key
      say("   One of the SSH host keys for node '#{node.name}' is better than what you currently have trusted.")
      say("     Current key: #{current_key.summary}")
      say("     Better key: #{best_key.summary}")
      if agree("   Do you want to use the better key? ")
        write_file! [:node_ssh_pub_key, node.name], best_key.to_s
      end
    else
      log(3, "current host key does not need updating")
    end
  end

end; end
