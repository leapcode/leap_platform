#
# Configuration for a 'node' (a server in the provider's infrastructure)
#

require 'ipaddr'

module LeapCli; module Config

  class Node < Object
    attr_accessor :file_paths

    def initialize(environment=nil)
      super(environment)
      @node = self
      @file_paths = []
    end

    #
    # returns true if this node has an ip address in the range of the vagrant network
    #
    def vagrant?
      ip = self['ip_address']
      return false unless ip
      begin
        vagrant_range = IPAddr.new LeapCli.leapfile.vagrant_network
      rescue ArgumentError
        Util::bail! { Util::log :invalid, "vagrant_network in Leapfile or .leaprc" }
      end

      begin
        ip_addr = IPAddr.new(ip)
      rescue ArgumentError
        Util::log :warning, "invalid ip address '#{ip}' for node '#{@node.name}'"
      end
      return vagrant_range.include?(ip_addr)
    end

    def vm?
      self['vm']
    end

    def vm_id?
      self['vm.id'] && !self['vm.id'].empty?
    end

    #
    # Return a hash table representation of ourselves, with the key equal to the @node.name,
    # and the value equal to the fields specified in *keys.
    #
    # Also, the result is flattened to a single hash, so a key of 'a.b' becomes 'a_b'
    #
    # compare to Object#pick(*keys). This method is the sames as Config::ObjectList#pick_fields,
    # but works on a single node.
    #
    # Example:
    #
    #  node.pick('domain.internal') =>
    #
    #    {
    #      'node1': {
    #        'domain_internal': 'node1.example.i'
    #      }
    #    }
    #
    def pick_fields(*keys)
      {@node.name => self.pick(*keys)}
    end

    #
    # can be overridden by the platform.
    # returns a list of node names that should be tested before this node
    #
    def test_dependencies
      []
    end

    # returns a string list of supported ssh host key algorithms for this node.
    # or an empty string if it could not be determined
    def supported_ssh_host_key_algorithms
      require 'leap_cli/ssh'
      @host_key_algo ||= LeapCli::SSH::Key.supported_host_key_algorithms(
        Util.read_file([:node_ssh_pub_key, @node.name])
      )
    end

    #
    # Takes strings such as "openvpn.gateway_address:1.1.1.1"
    # and converts this to data stored in this node.
    #
    def seed_from_args(args)
      args.each do |seed|
        key, value = seed.split(':', 2)
        value = format_seed_value(value)
        Util.assert! key =~ /^[0-9a-z\._]+$/, "illegal characters used in property '#{key}'"
        if key =~ /\./
          key_parts = key.split('.')
          final_key = key_parts.pop
          current_object = self
          key_parts.each do |key_part|
            current_object[key_part] ||= Config::Object.new
            current_object = current_object[key_part]
          end
          current_object[final_key] = value
        else
          self[key] = value
        end
      end
    end

    #
    # Seeds values for this node from a template, based on the services.
    # Values in the template will not override existing node values.
    #
    def seed_from_template
      inherit_from!(manager.template('common'))
      [self['services']].flatten.each do |service|
        if service
          template = manager.template(service)
          if template
            inherit_from!(template)
          end
        end
      end
    end

    #
    # bails if the node is not valid.
    #
    def validate!
      #
      # validate ip_address
      #
      if self['ip_address'] == "REQUIRED"
        Util.bail! do
          Util.log :error, "ip_address is not set. " +
            "Specify with `leap node add NAME ip_address:ADDRESS`."
        end
      elsif self['ip_address']
        begin
          IPAddr.new(self['ip_address'])
        rescue ArgumentError
          Util.bail! do
            Util.log :invalid, "ip_address #{self['ip_address'].inspect}"
          end
        end
      end

      #
      # validate name
      #
      self.class.validate_name!(self.name, self.vagrant?)
    end

    #
    # create or update all the configs needed for this node,
    # including x.509 certs as needed.
    #
    # note: this method will write to disk EVERYTHING
    # in the node, which is not what you want
    # if the node has inheritance applied.
    #
    def write_configs
      json = self.dump_json(:exclude => ['name'])
      Util.write_file!([:node_config, name], json + "\n")
    rescue LeapCli::ConfigError
      Config::Node.remove_node_files(self.name)
    end

    #
    # modifies the config file nodes/NAME.json for this node.
    #
    def update_json(new_values)
      self.env.update_node_json(node, new_values)
    end

    #
    # returns an array of all possible dns names for this node
    #
    def all_dns_names
      names = [@node.domain.internal, @node.domain.full]
      if @node['dns'] && @node.dns['aliases'] && @node.dns.aliases.any?
        names += @node.dns.aliases
      end
      names.compact!
      names.sort!
      names.uniq!
      return names
    end

    def remove_files
      self.class.remove_node_files(self.name)
    end

    ##
    ## Class Methods
    ##

    def self.remove_node_files(node_name)
      (Leap::Platform.node_files + [:node_files_dir]).each do |path|
        Util.remove_file! [path, node_name]
      end
    end

    def self.validate_name!(name, local=false)
      Util.assert! name, 'Node is missing a name.'
      if local
        Util.assert! name =~ /^[0-9a-z]+$/,
          "illegal characters used in node name '#{name}' " +
          "(note: Vagrant does not allow hyphens or underscores)"
      else
        Util.assert! name =~ /^[0-9a-z-]+$/,
          "illegal characters used in node name '#{name}' " +
          "(note: Linux does not allow underscores)"
      end
    end

    private

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

  end

end; end
