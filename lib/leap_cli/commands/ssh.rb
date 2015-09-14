module LeapCli; module Commands

  desc 'Log in to the specified node with an interactive shell.'
  arg_name 'NAME' #, :optional => false, :multiple => false
  command :ssh do |c|
    c.flag 'ssh', :desc => "Pass through raw options to ssh (e.g. `--ssh '-F ~/sshconfig'`)."
    c.flag 'port', :arg_name => 'SSH_PORT', :desc => 'Override default SSH port used when trying to connect to the server. Same as `--ssh "-p SSH_PORT"`.'
    c.action do |global_options,options,args|
      exec_ssh(:ssh, options, args)
    end
  end

  desc 'Log in to the specified node with an interactive shell using mosh (requires node to have mosh.enabled set to true).'
  arg_name 'NAME'
  command :mosh do |c|
    c.flag 'ssh', :desc => "Pass through raw options to ssh (e.g. `--ssh '-F ~/sshconfig'`)."
    c.flag 'port', :arg_name => 'SSH_PORT', :desc => 'Override default SSH port used when trying to connect to the server. Same as `--ssh "-p SSH_PORT"`.'
    c.action do |global_options,options,args|
      exec_ssh(:mosh, options, args)
    end
  end

  desc 'Creates an SSH port forward (tunnel) to the node NAME. REMOTE_PORT is the port on the remote node that the tunnel will connect to. LOCAL_PORT is the optional port on your local machine. For example: `leap tunnel couch1:5984`.'
  arg_name '[LOCAL_PORT:]NAME:REMOTE_PORT'
  command :tunnel do |c|
    c.flag 'ssh', :desc => "Pass through raw options to ssh (e.g. --ssh '-F ~/sshconfig')."
    c.flag 'port', :arg_name => 'SSH_PORT', :desc => 'Override default SSH port used when trying to connect to the server. Same as `--ssh "-p SSH_PORT"`.'
    c.action do |global_options,options,args|
      local_port, node, remote_port = parse_tunnel_arg(args.first)
      unless node.ssh.config.AllowTcpForwarding == "yes"
        log :warning, "It looks like TCP forwarding is not enabled. "+
          "The tunnel command requires that the node property ssh.config.AllowTcpForwarding "+
          "be set to 'yes'. Add this property to #{node.name}.json, deploy, and then try tunnel again."
      end
      options[:ssh] = [options[:ssh], "-N -L 127.0.0.1:#{local_port}:0.0.0.0:#{remote_port}"].join(' ')
      log("Forward port localhost:#{local_port} to #{node.name}:#{remote_port}")
      if is_port_available?(local_port)
        exec_ssh(:ssh, options, [node.name])
      end
    end
  end

  desc 'Secure copy from FILE1 to FILE2. Files are specified as NODE_NAME:FILE_PATH. For local paths, omit "NODE_NAME:".'
  arg_name 'FILE1 FILE2'
  command :scp do |c|
    c.switch :r, :desc => 'Copy recursively'
    c.action do |global_options, options, args|
      if args.size != 2
        bail!('You must specificy both FILE1 and FILE2')
      end
      from, to = args
      if (from !~ /:/ && to !~ /:/) || (from =~ /:/ && to =~ /:/)
        bail!('One FILE must be remote and the other local.')
      end
      src_node_name = src_file_path = src_node = nil
      dst_node_name = dst_file_path = dst_node = nil
      if from =~ /:/
        src_node_name, src_file_path = from.split(':')
        src_node = get_node_from_args([src_node_name], :include_disabled => true)
        dst_file_path = to
      else
        dst_node_name, dst_file_path = to.split(':')
        dst_node = get_node_from_args([dst_node_name], :include_disabled => true)
        src_file_path = from
      end
      exec_scp(options, src_node, src_file_path, dst_node, dst_file_path)
    end
  end

  protected

  #
  # allow for ssh overrides of all commands that use ssh_connect
  #
  def connect_options(options)
    connect_options = {:ssh_options=>{}}
    if options[:port]
      connect_options[:ssh_options][:port] = options[:port]
    end
    if options[:ip]
      connect_options[:ssh_options][:host_name] = options[:ip]
    end
    return connect_options
  end

  def ssh_config_help_message
    puts ""
    puts "Are 'too many authentication failures' getting you down?"
    puts "Then we have the solution for you! Add something like this to your ~/.ssh/config file:"
    puts "  Host *.#{manager.provider.domain}"
    puts "  IdentityFile ~/.ssh/id_rsa"
    puts "  IdentitiesOnly=yes"
    puts "(replace `id_rsa` with the actual private key filename that you use for this provider)"
  end

  require 'socket'
  def is_port_available?(port)
    TCPServer.open('127.0.0.1', port) {}
    true
  rescue Errno::EACCES
    bail!("You don't have permission to bind to port #{port}.")
  rescue Errno::EADDRINUSE
    bail!("Local port #{port} is already in use. Specify LOCAL_PORT to pick another.")
  rescue Exception => exc
    bail!(exc.to_s)
  end

  private

  def exec_ssh(cmd, cli_options, args)
    node = get_node_from_args(args, :include_disabled => true)
    port = node.ssh.port
    options = ssh_config(node)
    username = 'root'
    if LeapCli.log_level >= 3
      options << "-vv"
    elsif LeapCli.log_level >= 2
      options << "-v"
    end
    if cli_options[:port]
      port = cli_options[:port]
    end
    if cli_options[:ssh]
      options << cli_options[:ssh]
    end
    ssh = "ssh -l #{username} -p #{port} #{options.join(' ')}"
    if cmd == :ssh
      command = "#{ssh} #{node.domain.full}"
    elsif cmd == :mosh
      command = "MOSH_TITLE_NOPREFIX=1 mosh --ssh \"#{ssh}\" #{node.domain.full}"
    end
    log 2, command

    # exec the shell command in a subprocess
    pid = fork { exec "#{command}" }

    Signal.trap("SIGINT") do
      Process.kill("KILL", pid)
      Process.wait(pid)
      exit(0)
    end

    # wait for shell to exit so we can grab the exit status
    _, status = Process.waitpid2(pid)

    if status.exitstatus == 255
      ssh_config_help_message
    elsif status.exitstatus != 0
      exit(status.exitstatus)
    end
  end

  def exec_scp(cli_options, src_node, src_file_path, dst_node, dst_file_path)
    node = src_node || dst_node
    options = ssh_config(node)
    port = node.ssh.port
    username = 'root'
    options << "-r" if cli_options[:r]
    scp = "scp -P #{port} #{options.join(' ')}"
    if src_node
      command = "#{scp} #{username}@#{src_node.domain.full}:#{src_file_path} #{dst_file_path}"
    elsif dst_node
      command = "#{scp} #{src_file_path} #{username}@#{dst_node.domain.full}:#{dst_file_path}"
    end
    log 2, command

    # exec the shell command in a subprocess
    pid = fork { exec "#{command}" }

    Signal.trap("SIGINT") do
      Process.kill("KILL", pid)
      Process.wait(pid)
      exit(0)
    end

    # wait for shell to exit so we can grab the exit status
    _, status = Process.waitpid2(pid)
    exit(status.exitstatus)
  end

  #
  # SSH command line -o options. See `man ssh_config`
  #
  # NOTES:
  #
  # The option 'HostKeyAlias=#{node.name}' is oddly incompatible with ports in
  # known_hosts file, so we must not use this or non-standard ports break.
  #
  def ssh_config(node)
    options = [
      "-o 'HostName=#{node.ip_address}'",
      "-o 'GlobalKnownHostsFile=#{path(:known_hosts)}'",
      "-o 'UserKnownHostsFile=/dev/null'"
    ]
    if node.vagrant?
      options << "-i #{vagrant_ssh_key_file}"    # use the universal vagrant insecure key
      options << "-o IdentitiesOnly=yes"         # force the use of the insecure vagrant key
      options << "-o 'StrictHostKeyChecking=no'" # blindly accept host key and don't save it
                                                 # (since userknownhostsfile is /dev/null)
    else
      options << "-o 'StrictHostKeyChecking=yes'"
    end
    if !node.supported_ssh_host_key_algorithms.empty?
      options << "-o 'HostKeyAlgorithms=#{node.supported_ssh_host_key_algorithms}'"
    end
    return options
  end

  def parse_tunnel_arg(arg)
    if arg.count(':') == 1
      node_name, remote = arg.split(':')
      local = nil
    elsif arg.count(':') == 2
      local, node_name, remote = arg.split(':')
    else
      bail!('Argument NAME:REMOTE_PORT required.')
    end
    node = get_node_from_args([node_name], :include_disabled => true)
    remote = remote.to_i
    local = local || remote
    local = local.to_i
    return [local, node, remote]
  end

end; end