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
      add.switch :local, :desc => 'Make a local testing node (by automatically assigning the next available local IP address). Local nodes are run as virtual machines on your computer.', :negatable => false
      add.action do |global_options,options,args|
        add_node(global_options, options, args)
      end
    end

    node.desc 'Renames a node file, and all its related files.'
    node.arg_name 'OLD_NAME NEW_NAME'
    node.command :mv do |mv|
      mv.action do |global_options,options,args|
        move_node(global_options, options, args)
      end
    end

    node.desc 'Removes all the files related to the node named NAME.'
    node.arg_name 'NAME' #:optional => false #, :multiple => false
    node.command :rm do |rm|
      rm.action do |global_options,options,args|
        rm_node(global_options, options, args)
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

  def add_node(global, options, args)
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

  def move_node(global, options, args)
    node = get_node_from_args(args, include_disabled: true)
    new_name = args.last
    Config::Node.validate_name!(new_name, node.vagrant?)
    ensure_dir [:node_files_dir, new_name]
    Leap::Platform.node_files.each do |path|
      rename_file! [path, node.name], [path, new_name]
    end
    remove_directory! [:node_files_dir, node.name]
    rename_node_facts(node.name, new_name)
  end

  def rm_node(global, options, args)
    node = get_node_from_args(args, include_disabled: true)
    node.remove_files
    if node.vagrant?
      vagrant_command("destroy --force", [node.name])
    end
    remove_node_facts(node.name)
  end

end; end
