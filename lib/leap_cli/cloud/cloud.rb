#
# An abstractions in front of Fog, which is an abstraction in front of
# the AWS api. Oh my!
#
# A Cloud object binds a particular node with particular Fog
# authentication credentials.
#
# NOTE: Possible AWS options for creating instances:
#
# options = {
#   'BlockDeviceMapping'          => block_device_mapping,
#   'NetworkInterfaces'           => network_interfaces,
#   'ClientToken'                 => client_token,
#   'DisableApiTermination'       => disable_api_termination,
#   'EbsOptimized'                => ebs_optimized,
#   'IamInstanceProfile.Arn'      => @iam_instance_profile_arn,
#   'IamInstanceProfile.Name'     => @iam_instance_profile_name,
#   'InstanceInitiatedShutdownBehavior' => instance_initiated_shutdown_behavior,
#   'InstanceType'                => flavor_id,
#   'KernelId'                    => kernel_id,
#   'KeyName'                     => key_name,
#   'Monitoring.Enabled'          => monitoring,
#   'Placement.AvailabilityZone'  => availability_zone,
#   'Placement.GroupName'         => placement_group,
#   'Placement.Tenancy'           => tenancy,
#   'PrivateIpAddress'            => private_ip_address,
#   'RamdiskId'                   => ramdisk_id,
#   'SecurityGroup'               => groups,
#   'SecurityGroupId'             => security_group_ids,
#   'SubnetId'                    => subnet_id,
#   'UserData'                    => user_data,
# }
#

module LeapCli
  class Cloud
    LEAP_SG_NAME = 'leap_default'
    LEAP_SG_DESC = 'Default security group for LEAP nodes'

    include LeapCli::LogCommand

    attr_reader :compute  # Fog::Compute object
    attr_reader :node     # Config::Node, if any
    attr_reader :options  # options for the VMs, if any
    attr_reader :image    # which vm image to use, if any
    attr_reader :name     # name of which entry in cloud.json to use

    def initialize(name, conf, node=nil)
      @node = node
      @name = name
      @conf = conf
      @compute = nil
      @options = nil
      @image = nil

      raise ArgumentError, 'name missing' unless @name
      raise ArgumentError, 'config missing' unless @conf
      raise ArgumentError, 'config auth missing' unless @conf["auth"]
      raise ArgumentError, 'config auth missing' unless @conf["vendor"]

      credentials = @conf["auth"].symbolize_keys
      credentials[:provider] = @conf["vendor"]
      @compute = Fog::Compute.new(credentials)

      @options = @conf['default_options'] || {}
      @image   = @conf['default_image'] || aws_image(credentials[:region])
      if @node
        @options = node.vm.options if node['vm.options']
        @image   = node.vm.image if node['vm.image']
      end
    end

    #
    # fetches or creates a server for this cloud object.
    #
    def fetch_or_create_server(options)
      fetch_server_for_node || create_new_vm_instance(choose_ssh_key: options[:choose_ssh_key])
    end

    #
    # fetches the server for a particular node.
    #
    # return nil if this cloud object has no node, or there is no corresponding
    # server.
    #
    def fetch_server_for_node(bail_on_failure=false)
      server = nil
      return nil unless @node

      # does an instance exist that matches the node's vm.id?
      if @node.vm_id?
        instance_id = @node.vm.id
        server = @compute.servers.get(instance_id)
      end

      # does an instance exist that is tagged with this node name?
      if server.nil?
        response = @compute.describe_instances({"tag:node_name" => @node.name})
        # puts JSON.pretty_generate(response.body)
        if !response.body["reservationSet"].empty?
          instances = response.body["reservationSet"].first["instancesSet"]
          if instances.size > 1
            bail! "There are multiple VMs with the same node name tag! Manually remove one before continuing."
          elsif instances.size == 1
            instance_id = instances.first["instanceId"]
            server = @compute.servers.get(instance_id)
          end
        end
      end

      if server.nil? && bail_on_failure
        bail! :error, "A virtual machine could not be found for node `#{@node.name}`. Things to try:" do
          log "check the output of `leap vm status`"
          log "check the value of `vm.id` in #{@node.name}.json"
          log "run `leap vm add #{@node.name}` to create a corresponding virtual machine"
        end
      end

      return server
    end

    #
    # associates a node with a vm
    #
    def bind_server_to_node(server)
      unless @node
        raise ArgumentError, 'no node'
      end
      unless server.state == 'running'
        bail! do
          log 'The virtual machine `%s` must be running in order to bind it to the configuration `%s`.' % [
            server.id, Path.relative_path(Path.named_path([:node_config, @node.name]))]
          log 'To fix, run `leap vm start %s`' % server.id
        end
      end

      # assign tag
      @compute.create_tags(server.id, {'node_name' => @node.name})
      log :created, "association between node '%s' and vm '%s'" % [@node.name, server.id]

      # update node json
      @node.update_json({
        "ip_address" => server.public_ip_address,
        "vm"=> {"id"=>server.id}
      })
      log "done", :color => :green, :style => :bold
    end

    #
    # disassociates a node from a vm
    #
    def unbind_server_from_node(server)
      raise ArgumentError, 'no node' unless @node

      # assign tag
      @compute.delete_tags(server.id, {'node_name' => @node.name})
      log :removed, "association between node '%s' and vm '%s'" % [@node.name, server.id]

      # update node json
      @node.update_json({
        "ip_address" => '0.0.0.0',
        "vm"=> {"id" => ""}
      })
    end

    #
    # return an AWS KeyPair object, potentially uploading it to the server
    # if necessary.
    #
    # this is used when initially creating the vm. After the first `node init`, then
    # all sysadmins should have access to the server.
    #
    # NOTE: ssh and aws use different types of fingerprint
    #
    def find_or_create_key_pair(pick_ssh_key_method)
      require 'leap_cli/ssh'
      key_pair, local_key = match_ssh_key(:user_only => true)
      if key_pair
        log :using, "SSH key #{local_key.filename}" do
          log 'AWS MD5 fingerprint: ' + local_key.fingerprint(:digest => :md5, :type => :der, :encoding => :hex)
          log 'SSH MD5 fingerprint: ' + local_key.fingerprint(:digest => :md5, :type => :ssh, :encoding => :hex)
          log 'SSH SHA256 fingerprint: ' + local_key.fingerprint(:digest => :sha256, :type => :ssh, :encoding => :base64)
        end
      elsif key_pair.nil?
        username, key = pick_ssh_key_method.call(self)
        key_pair = upload_ssh_key(username, key)
      end
      return key_pair
    end

    #
    # checks if there is a match between a local key and a registered key_pair
    #
    # options:
    #   :key_pair -- limit comparisons to this key_pair object.
    #   :user_only -- limit comparisons to the user's ~/.ssh directory only
    #
    # returns:
    #
    #   key_pair -- an AWS KeyPair
    #   local_key -- a LeapCLi::SSH::Key
    #
    def match_ssh_key(options={})
      key_pair = options[:key_pair]
      local_keys_to_check = LeapCli::SSH::Key.my_public_keys
      unless options[:user_only]
        local_keys_to_check += LeapCli::SSH::Key.provider_public_keys
      end
      fingerprints = Hash[local_keys_to_check.map {|k|
        [k.fingerprint(:digest => :md5, :type => :der, :encoding => :hex), k]
      }]
      key_pair ||= @compute.key_pairs.select {|key_pair|
        fingerprints.include?(key_pair.fingerprint)
      }.first
      if key_pair
        local_key = fingerprints[key_pair.fingerprint]
        return key_pair, local_key
      else
        return nil, nil
      end
    end

    private

    #
    # Every AWS instance requires a security group, which is just a simple firewall.
    # In the future, we could create a separate security group for each node,
    # and set the rules to match what the rules should be for that node.
    #
    # However, for now, we just use a security group 'leap_default' that opens
    # all the ports.
    #
    # The default behavior for AWS security groups is:
    # all ingress traffic is blocked and all egress traffic is allowed.
    #
    def find_or_create_security_group
      group = @compute.security_groups.get(LEAP_SG_NAME)
      if group.nil?
        group = @compute.security_groups.create(
          :name => LEAP_SG_NAME,
          :description => LEAP_SG_DESC
        )
        group.authorize_port_range(0..65535,
          :ip_protocol => 'tcp',
          :cidr_ip => '0.0.0.0/0',
        )
        group.authorize_port_range(0..65535,
          :ip_protocol => 'udp',
          :cidr_ip => '0.0.0.0/0',
        )
      end
      return group
    end

    #
    # key - a LeapCli::SSH::Key object
    # returns -- AWS KeyPair
    #
    def upload_ssh_key(username, key)
      key_name = 'leap_' + username
      key_pair = @compute.key_pairs.create(
       :name => key_name,
       :public_key => key.public_key.to_s
      )
      log :registered, "public key" do
        log 'cloud provider: ' + @name
        log 'name: ' + key_name
        log 'AWS MD5 fingerprint: ' + key.fingerprint(:digest => :md5, :type => :der, :encoding => :hex)
        log 'SSH MD5 fingerprint: ' + key.fingerprint(:digest => :md5, :type => :ssh, :encoding => :hex)
        log 'SSH SHA256 fingerprint: ' + key.fingerprint(:digest => :sha256, :type => :ssh, :encoding => :base64)
      end
      return key_pair
    end

    def create_new_vm_instance(choose_ssh_key: nil)
      log :creating, "new vm instance..."
      assert! @image, "No image found. Specify `default_image` in cloud.json or `vm.image` in node's config."
      if Fog.mock?
        options = @options
      else
        key_pair       = find_or_create_key_pair(choose_ssh_key)
        security_group = find_or_create_security_group
        options = @options.merge({
          'KeyName' => key_pair.name,
          'SecurityGroup' => security_group.name
        })
      end
      response = @compute.run_instances(
        @image,
        1, # min count
        1, # max count
        options
      )
      instance_id = response.body["instancesSet"].first["instanceId"]
      log :created, "vm with instance id #{instance_id}."
      server = @compute.servers.get(instance_id)
      if server.nil?
        bail! :error, "could not query instance '#{instance_id}'."
      end
      unless Fog.mock?
        tries = 0
        server.wait_for {
          if tries > 0
            LeapCli.log :waiting, "for IP address to be assigned..."
          end
          tries += 1
          !public_ip_address.nil?
        }
        if options[:wait]
          log :waiting, "for vm #{instance_id} to start..."
          server.wait_for { ready? }
          log :started, "#{instance_id} with #{server.public_ip_address}"
        end
      end
      return server
    end

  end
end