module LeapCli; module Commands

  desc "Manage virtual machines."
  long_desc "This command provides a convenient way to manage virtual machines. " +
            "FILTER may be a node filter or the ID of a virtual machine."

  command [:vm] do |vm|
    vm.switch :mock, :desc => "Run as simulation, without actually connecting to a cloud provider. If set, --auth is ignored."
    vm.switch :wait, :desc => "Wait for servers to start/stop before continuing."
    vm.flag :auth,  :arg_name => 'AUTH',
      :desc => "Choose which authentication credentials to use from the file cloud.json. "+
               "If omitted, will default to the node's `vm.auth` property, or the first credentials in cloud.json"

    vm.desc "Allocates a new virtual machine and/or associates it with node NAME. "+
            "If node configuration file does not yet exist, "+
            "it is created with the optional SEED values. "+
            "You can run this command when the virtual machine already exists "+
            "in order to update the node's `vm.id` property."
    vm.arg_name 'NODE_NAME [SEED]'
    vm.command :add do |cmd|
      cmd.action do |global, options, args|
        do_vm_add(global, options, args)
      end
    end

    vm.desc 'Starts the virtual machine(s)'
    vm.arg_name 'FILTER', :optional => true
    vm.command :start do |start|
      start.action do |global, options, args|
        do_vm_start(global, options, args)
      end
    end

    vm.desc 'Shuts down the virtual machine(s), but keeps the storage allocated (to save resources, run `leap vm rm` instead).'
    vm.arg_name 'FILTER', :optional => true
    vm.command :stop do |stop|
      stop.action do |global, options, args|
        do_vm_stop(global, options, args)
      end
    end

    vm.desc 'Destroys the virtual machine(s)'
    vm.arg_name 'FILTER', :optional => true
    vm.command :rm do |rm|
      rm.action do |global, options, args|
        do_vm_rm(global, options, args)
      end
    end

    vm.desc 'Print the status of virtual machine(s)'
    vm.arg_name 'FILTER', :optional => true
    vm.command [:status, :ls] do |status|
      status.action do |global, options, args|
        do_vm_status(global, options, args)
      end
    end

    vm.desc "Binds a running virtual machine instance to a node configuration. "+
            "Afterwards, the VM will be assigned a label matching the node name, "+
            "and the node config will be updated with the instance ID."
    vm.arg_name 'NODE_NAME INSTANCE_ID'
    vm.command 'bind' do |cmd|
      cmd.action do |global, options, args|
        do_vm_bind(global, options, args)
      end
    end

    vm.desc "Registers a SSH public key for use when creating new virtual machines. "+
            "Note that only people who are creating new VM instances need to "+
            "have their key registered."
    vm.command 'key-register' do |cmd|
      cmd.action do |global, options, args|
        do_vm_key_register(global, options, args)
      end
    end

    vm.desc "Lists the registered SSH public keys for a particular virtual "+
            "machine provider."
    vm.command 'key-list' do |cmd|
      cmd.action do |global, options, args|
        do_vm_key_list(global, options, args)
      end
    end

    #vm.desc 'Saves the current state of the virtual machine as a new snapshot.'
    #vm.arg_name 'FILTER', :optional => true
    #vm.command :save do |save|
    #  save.action do |global, options, args|
    #    do_vm_save(global, options, args)
    #  end
    #end

    #vm.desc 'Resets virtual machine(s) to the last saved snapshot'
    #vm.arg_name 'FILTER', :optional => true
    #vm.command :reset do |reset|
    #  reset.action do |global, options, args|
    #    do_vm_reset(global, options, args)
    #  end
    #end

    #vm.desc 'Lists the available images.'
    #vm.command 'image-list' do |cmd|
    #  cmd.action do |global, options, args|
    #    do_vm_image_list(global, options, args)
    #  end
    #end
  end

  ##
  ## SHARED UTILITY METHODS
  ##

  protected

  #
  # a callback used if we need to upload a new ssh key
  #
  def choose_ssh_key_for_upload(cloud)
    puts
    bail! unless agree("The cloud provider `#{cloud.name}` does not have "+
          "your public key. Do you want to upload one? ")
    key = pick_ssh_key
    username = ask("username? ", :default => `whoami`.strip)
    assert!(username && !username.empty? && username =~ /[0-9a-z_-]+/, "Username must consist of one or more letters or numbers")
    puts
    return username, key
  end

  def bind_server_to_node(vm_id, node, options={})
    cloud  = new_cloud_handle(node, options)
    server = cloud.compute.servers.get(vm_id)
    assert! server, "Could not find a VM instance with ID '#{vm_id}'"
    cloud.bind_server_to_node(server)
  end

  ##
  ## COMMANDS
  ##

  protected

  #
  # entirely removes the vm, not just stopping it.
  #
  # This might be additionally called by the 'leap node rm' command.
  #
  def do_vm_rm(global, options, args)
    servers_from_args(global, options, args) do |cloud, server|
      cloud.unbind_server_from_node(server) if cloud.node
      destroy_server(server, options[:wait])
    end
  end

  private

  def do_vm_status(global, options, args)
    cloud = new_cloud_handle(nil, options)
    servers = cloud.compute.servers

    #
    # PRETTY TABLE
    #
    t = LeapCli::Util::ConsoleTable.new
    t.table do
      t.row(color: :cyan) do
        t.column "ID"
        t.column "NODE"
        t.column "STATE"
        t.column "FLAVOR"
        t.column "IP"
        t.column "ZONE"
      end
      servers.each do |server|
        t.row do
          t.column server.id
          t.column server.tags["node_name"]
          t.column server.state, :color => state_color(server.state)
          t.column server.flavor_id
          t.column server.public_ip_address
          t.column server.availability_zone
        end
      end
    end
    puts
    t.draw_table

    #
    # SANITY CHECKS
    #
    servers.each do |server|
      name = server.tags["node_name"]
      if name
        node = manager.nodes[name]
        if node.nil?
          log :warning, 'A virtual machine has the name `%s`, but there is no corresponding node definition in `%s`.' % [
            name, relative_path(path([:node_config, name]))]
          next
        end
        if node['vm'].nil?
          log :warning, 'Node `%s` is not configured as a virtual machine' % name do
            log 'You should fix this with `leap vm bind %s %s`' % [name, server.id]
          end
          next
        end
        if node['vm.id'] != server.id
          message = 'Node `%s` is configured with virtual machine id `%s`' % [name, node['vm.id']]
          log :warning, message do
            log 'But the virtual machine with that name really has id `%s`' % server.id
            log 'You should fix this with `leap vm bind %s %s`' % [name, server.id]
          end
        end
        if server.state == 'running'
          if node.ip_address != server.public_ip_address
            message = 'The configuration file for node `%s` has IP address `%s`' % [name, node.ip_address]
            log(:warning, message) do
              log 'But the virtual machine actually has IP address `%s`' % server.public_ip_address
              log 'You should fix this with `leap vm add %s`' % name
            end
          end
        end
      end
    end
    manager.filter(['vm']).each_node do |node|
      if node['vm.id'].nil?
        log :warning, 'The node `%s` is missing a server id' % node.name
        next
      end
      if !servers.detect {|s| s.id == node.vm.id }
        message = "The configuration file for node `%s` has virtual machine id of `%s`" % [node.name, node.vm.id]
        log :warning, message do
          log "But that does not match any actual virtual machines!"
        end
      end
      if !servers.detect {|s| s.tags["node_name"] == node.name }
        log :warning, "The node `%s` has no virtual machines with a matching name." % node.name do
          server = servers.detect {|s| s.id == node.vm.id }
          if server
            log 'Run `leap bind %s %s` to fix this' % [node.name, server.id]
          end
        end
      end
    end
  end

  def do_vm_add(global, options, args)
    name = args.first
    if manager.nodes[name].nil?
      do_node_add(global, {:ip_address => '0.0.0.0'}.merge(options), args)
    end
    node   = manager.nodes[name]
    cloud  = new_cloud_handle(node, options)
    server = cloud.fetch_or_create_server(:choose_ssh_key => method(:choose_ssh_key_for_upload))

    if server
      cloud.bind_server_to_node(server)
    end
  end

  def do_vm_start(global, options, args)
    servers_from_args(global, options, args) do |cloud, server|
      start_server(server, options[:wait])
    end
  end

  def do_vm_stop(global, options, args)
    servers_from_args(global, options, args) do |cloud, server|
      stop_server(server, options[:wait])
    end
  end

  def do_vm_key_register(global, options, args)
    cloud = new_cloud_handle(nil, options)
    cloud.find_or_create_key_pair(method(:choose_ssh_key_for_upload))
  end

  def do_vm_key_list(global, options, args)
    require 'leap_cli/ssh'
    cloud = new_cloud_handle(nil, options)
    cloud.compute.key_pairs.each do |key_pair|
      log key_pair.name, :color => :cyan do
        log "AWS fingerprint: " + key_pair.fingerprint
        key_pair, local_key = cloud.match_ssh_key(:key_pair => key_pair)
        if local_key
          log "matches local key: " + local_key.filename
          log 'SSH MD5 fingerprint: ' + local_key.fingerprint(:digest => :md5, :type => :ssh, :encoding => :hex)
          log 'SSH SHA256 fingerprint: ' + local_key.fingerprint(:digest => :sha256, :type => :ssh, :encoding => :base64)
        end
      end
    end
  end

  #
  # update association between node and virtual machine.
  #
  # This might additionally be called by the 'leap node mv' command.
  #
  def do_vm_bind(global, options, args)
    node_name = args.first
    vm_id = args.last
    assert! node_name, "NODE_NAME is missing"
    assert! vm_id, "INSTANCE_ID is missing"
    node = manager.nodes[node_name]
    assert! node, "No node with name '#{node_name}'"
    bind_server_to_node(vm_id, node, options)
  end

  #def do_vm_image_list(global, options, args)
  #  compute = fog_setup(nil, options)
  #  p compute.images.all
  #end

  ##
  ## PRIVATE UTILITY METHODS
  ##

  def stop_server(server, wait=false)
    if server.state == 'stopped'
      log :skipping, "virtual machine `#{server.id}` (already stopped)."
    elsif ['shutting-down', 'terminated'].include?(server.state)
      log :skipping, "virtual machine `#{server.id}` (being destroyed)."
    else
      log :stopping, "virtual machine `#{server.id}` (#{server.flavor_id}, #{server.availability_zone})"
      server.stop
      if wait
        log 'please wait...', :indent => 1
        server.wait_for { state == 'stopped' }
        log 'done', :color => :green, :indent => 1
      end
    end
  end

  def start_server(server, wait=false)
    if server.state == 'running'
      log :skipping, "virtual machine `#{server.id}` (already running)."
    elsif ['shutting-down', 'terminated'].include?(server.state)
      log :skipping, "virtual machine `#{server.id}` (being destroyed)."
    else
      log :starting, "virtual machine `#{server.id}` (#{server.flavor_id}, #{server.availability_zone})"
      server.start
      if wait
        log 'please wait...', :indent => 1
        server.wait_for { ready? }
        log 'done', :color => :green, :indent => 1
      end
    end
  end

  def destroy_server(server, wait=false)
    if ['shutting-down', 'terminated'].include?(server.state)
      log :skipping, "virtual machine `#{server.id}` (already being removed)."
    else
      log :terminated, "virtual machine `#{server.id}` (#{server.flavor_id}, #{server.availability_zone})"
      server.destroy
      if wait
        log 'please wait...', :indent => 1
        server.wait_for { state == 'terminated' }
        log 'done', :color => :green, :indent => 1
      end
    end
  end

  #
  # for each server it finds, yields cloud, server
  #
  def servers_from_args(global, options, args)
    nodes = filter_vm_nodes(args)
    if nodes.any?
      nodes.each_node do |node|
        cloud  = new_cloud_handle(node, options)
        server = cloud.fetch_server_for_node(true)
        yield cloud, server
      end
    else
      instance_id = args.first
      cloud  = new_cloud_handle(nil, options)
      server = cloud.compute.servers.get(instance_id)
      if server.nil?
        bail! :error, "There is no virtual machine with ID `#{instance_id}`."
      end
      yield cloud, server
    end
  end

  #
  # returns either:
  #
  # * the set of nodes specified by the filter, for this environment
  #   even if the result includes nodes that are not previously tagged with 'vm'
  #
  # * the list of all vm nodes for this environment, if filter is empty
  #
  def filter_vm_nodes(filter)
    if filter.nil? || filter.empty?
      return manager.filter(['vm'], :warning => false)
    elsif filter.is_a? Array
      return manager.filter(filter, :warning => false)
    else
      raise ArgumentError, 'could not understand filter'
    end
  end

  def new_cloud_handle(node, options)
    require 'leap_cli/cloud'

    config = manager.env.cloud
    name = nil
    if options[:mock]
      Fog.mock!
      name = 'mock_aws'
      config['mock_aws'] = {
        "api" => "aws",
        "vendor" => "aws",
        "auth" => {
          "aws_access_key_id" => "dummy",
          "aws_secret_access_key" => "dummy",
          "region" => "us-west-2"
        },
        "instance_options" => {
          "image" => "dummy"
        }
      }
    elsif options[:auth]
      name = options[:auth]
      assert! config[name], "The value for --auth does not correspond to any value in cloud.json."
    elsif node && node['vm.auth']
      name = node.vm.auth
      assert! config[name], "The node '#{node.name}' has a value for property 'vm.auth' that does not correspond to any value in cloud.json."
    elsif config.keys.length == 1
      name = config.keys.first
      log :using, "cloud vendor credentials `#{name}`."
    else
      bail! "You must specify --mock, --auth, or a node filter."
    end

    entry = config[name] # entry in cloud.json
    assert! entry, "cloud.json: could not find cloud resource `#{name}`."
    assert! entry['vendor'], "cloud.json: property `vendor` is missing from `#{name}` entry."
    assert! entry['api'], "cloud.json: property `api` is missing from `#{name}` entry. It must be one of #{config.possible_apis.join(', ')}."
    assert! entry['auth'], "cloud.json: property `auth` is missing from `#{name}` entry."
    assert! entry['auth']['region'], "cloud.json: property `auth.region` is missing from `#{name}` entry."
    assert! entry['api'] == 'aws', "cloud.json: currently, only 'aws' is supported for `api`."
    assert! entry['vendor'] == 'aws', "cloud.json: currently, only 'aws' is supported for `vendor`."

    return LeapCli::Cloud.new(name, entry, node)
  end

  def state_color(state)
    case state
      when 'running'; :green
      when 'terminated'; :red
      when 'stopped'; :magenta
      when 'shutting-down'; :yellow
      else; :white
    end
  end

end; end
