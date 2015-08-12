#
# fyi: the `node init` command lives in node_init.rb,
#      but all other `node x` commands live here.
#

autoload :IPAddr, 'ipaddr'

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
                    "Separeate multiple values for a single property with a comma, like so: `leap node add mynode services:webapp,dns`"].join("\n\n")
    node.arg_name 'NAME [SEED]' # , :optional => false, :multiple => false
    node.command :add do |add|
      add.switch :local, :desc => 'Make a local testing node (by automatically assigning the next available local IP address). Local nodes are run as virtual machines on your computer.', :negatable => false
      add.action do |global_options,options,args|
        # argument sanity checks
        name = args.first
        assert_valid_node_name!(name, options[:local])
        assert_files_missing! [:node_config, name]

        # create and seed new node
        node = Config::Node.new(manager)
        if options[:local]
          node['ip_address'] = pick_next_vagrant_ip_address
        end
        seed_node_data(node, args[1..-1])
        validate_ip_address(node)
        begin
          write_file! [:node_config, name], node.dump_json + "\n"
          node['name'] = name
          if file_exists? :ca_cert, :ca_key
            generate_cert_for_node(manager.reload_node!(node))
          end
        rescue LeapCli::ConfigError => exc
          remove_node_files(name)
        end
      end
    end

    node.desc 'Renames a node file, and all its related files.'
    node.arg_name 'OLD_NAME NEW_NAME'
    node.command :mv do |mv|
      mv.action do |global_options,options,args|
        node = get_node_from_args(args)
        new_name = args.last
        assert_valid_node_name!(new_name, node.vagrant?)
        ensure_dir [:node_files_dir, new_name]
        Leap::Platform.node_files.each do |path|
          rename_file! [path, node.name], [path, new_name]
        end
        remove_directory! [:node_files_dir, node.name]
        rename_node_facts(node.name, new_name)
      end
    end

    node.desc 'Removes all the files related to the node named NAME.'
    node.arg_name 'NAME' #:optional => false #, :multiple => false
    node.command :rm do |rm|
      rm.action do |global_options,options,args|
        node = get_node_from_args(args)
        remove_node_files(node.name)
        if node.vagrant?
          vagrant_command("destroy --force", [node.name])
        end
        remove_node_facts(node.name)
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

  def seed_node_data(node, args)
    args.each do |seed|
      key, value = seed.split(':')
      value = format_seed_value(value)
      assert! key =~ /^[0-9a-z\._]+$/, "illegal characters used in property '#{key}'"
      if key =~ /\./
        key_parts = key.split('.')
        final_key = key_parts.pop
        current_object = node
        key_parts.each do |key_part|
          current_object[key_part] ||= Config::Object.new
          current_object = current_object[key_part]
        end
        current_object[final_key] = value
      else
        node[key] = value
      end
    end
  end

  def remove_node_files(node_name)
    (Leap::Platform.node_files + [:node_files_dir]).each do |path|
      remove_file! [path, node_name]
    end
  end

  #
  # conversions:
  #
  #   "x,y,z" => ["x","y","z"]
  #
  #   "22" => 22
  #
  #   "5.1" => 5.1
  #
  def format_seed_value(v)
    if v =~ /,/
      v = v.split(',')
      v.map! do |i|
        i = i.to_i if i.to_i.to_s == i
        i = i.to_f if i.to_f.to_s == i
        i
      end
    else
      v = v.to_i if v.to_i.to_s == v
      v = v.to_f if v.to_f.to_s == v
    end
    return v
  end

  def validate_ip_address(node)
    IPAddr.new(node['ip_address'])
  rescue ArgumentError
    bail! do
      if node['ip_address']
        log :invalid, "ip_address #{node['ip_address'].inspect}"
      else
        log :missing, "ip_address"
      end
    end
  end

  def assert_valid_node_name!(name, local=false)
    assert! name, 'No <node-name> specified.'
    if local
      assert! name =~ /^[0-9a-z]+$/, "illegal characters used in node name '#{name}' (note: Vagrant does not allow hyphens or underscores)"
    else
      assert! name =~ /^[0-9a-z-]+$/, "illegal characters used in node name '#{name}' (note: Linux does not allow underscores)"
    end
  end

end; end