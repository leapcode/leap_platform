#
# fyi: the `node init` command lives in node_init.rb,
#      but all other `node x` commands live here.
#

module LeapCli; module Commands

  ##
  ## COMMANDS
  ##

  desc 'Node management'
  command [:node, :n] do |node|
    node.desc 'Create a new configuration file for a node named NAME.'
    node.long_desc ["If specified, the optional argument SEED can be used to seed values in the node configuration file.",
                    "The format is property_name:value.",
                    "For example: `leap node add web1 ip_address:1.2.3.4 services:webapp`.",
                    "To set nested properties, property name can contain '.', like so: `leap node add web1 ssh.port:44`",
                    "Separate multiple values for a single property with a comma, like so: `leap node add mynode services:webapp,dns`"].join("\n\n")
    node.arg_name 'NAME [SEED]' # , :optional => false, :multiple => false
    node.command :add do |add|
      add.switch :local, :desc => 'Make a local testing node (by assigning the next available local IP address). Local nodes are run as virtual machines on your computer.', :negatable => false
      add.switch :vm, :desc => 'Make a remote virtual machine for this node. Requires a valid cloud.json configuration.', :negatable => false
      add.action do |global_options,options,args|
        if options[:vm]
          do_vm_add(global_options, options, args)
        else
          do_node_add(global_options, options, args)
        end
      end
    end

    node.desc 'Renames a node file, and all its related files.'
    node.arg_name 'OLD_NAME NEW_NAME'
    node.command :mv do |mv|
      mv.action do |global_options,options,args|
        do_node_move(global_options, options, args)
      end
    end

    node.desc 'Removes all the files related to the node named NAME.'
    node.arg_name 'NAME' #:optional => false #, :multiple => false
    node.command :rm do |rm|
      rm.action do |global_options,options,args|
        do_node_rm(global_options, options, args)
      end
    end

    node.desc 'Mark a node as disabled.'
    node.arg_name 'NAME'
    node.command :disable do |cmd|
      cmd.action do |global_options,options,args|
        do_node_disable(global_options, options, args)
      end
    end

    node.desc 'Mark a node as enabled.'
    node.arg_name 'NAME'
    node.command :enable do |cmd|
      cmd.action do |global_options,options,args|
        do_node_enable(global_options, options, args)
      end
    end

  end

  ##
  ## PUBLIC HELPERS
  ##

  def get_node_from_args(args, options={})
    node_name = args.first
    node = manager.node(node_name)
    if node.nil? && options[:include_disabled]
      node = manager.disabled_node(node_name)
    end
    assert!(node, "Node '#{node_name}' not found.")
    node
  end

  protected

  #
  # additionally called by `leap vm add`
  #
  def do_node_add(global, options, args)
    name = args.first
    unless global[:force]
      assert_files_missing! [:node_config, name]
    end
    node = Config::Node.new(manager.env)
    node['name'] = name
    if options[:ip_address]
      node['ip_address'] = options[:ip_address]
    elsif options[:local]
      node['ip_address'] = pick_next_vagrant_ip_address
    end
    node.seed_from_args(args[1..-1])
    node.seed_from_template
    node.validate!
    node.write_configs
    # reapply inheritance, since tags/services might have changed:
    node = manager.reload_node!(node)
    node.generate_cert
  end

  private

  def do_node_move(global, options, args)
    node = get_node_from_args(args, include_disabled: true)
    new_name = args.last
    Config::Node.validate_name!(new_name, node.vagrant?)
    ensure_dir [:node_files_dir, new_name]
    Leap::Platform.node_files.each do |path|
      rename_file! [path, node.name], [path, new_name]
    end
    remove_directory! [:node_files_dir, node.name]
    rename_node_facts(node.name, new_name)
    if node.vm_id?
      node['name'] = new_name
      bind_server_to_node(node.vm.id, node, options)
    end
  end

  def do_node_rm(global, options, args)
    node = get_node_from_args(args, include_disabled: true)
    if node.vm?
      if !node.vm_id?
        log :warning, "The node #{node.name} is missing a 'vm.id' property. "+
                      "You may have a virtual machine instance that is left "+
                      "running. Check `leap vm status`"
      else
        msg = "The node #{node.name} appears to be associated with a virtual machine. " +
              "Do you want to also destroy this virtual machine? "
        if global[:yes] || agree(msg)
          do_vm_rm(global, options, args)
        end
      end
    elsif node.vagrant?
      vagrant_command("destroy --force", [node.name])
    end
    node.remove_files
    remove_node_facts(node.name)
  end

  def do_node_enable(global, options, args)
    node = get_node_from_args(args, include_disabled: true)
    node.update_json({}, remove: ["enabled"])
  end

  def do_node_disable(global, options, args)
    node = get_node_from_args(args, include_disabled: true)
    node.update_json("enabled" => false)
  end

end; end
