# encoding: utf-8

module LeapCli
  module Macro

    ##
    ## HOSTS
    ##

    #
    # records the list of hosts that are encountered for this node
    #
    def hostnames(nodes)
      @referenced_nodes ||= Config::ObjectList.new
      nodes = listify(nodes)
      nodes.each_node do |node|
        @referenced_nodes[node.name] ||= node
      end
      return nodes.values.collect {|node| node.domain.name}
    end

    #
    # Generates entries needed for updating /etc/hosts on a node (as a hash).
    #
    # Argument `nodes` can be nil or a list of nodes. If nil, only include the
    # IPs of the other nodes this @node as has encountered (plus all mx nodes).
    #
    # Also, for virtual machines, we use the local address if this @node is in
    # the same location as the node in question.
    #
    # We include the ssh public key for each host, so that the hash can also
    # be used to generate the /etc/ssh/known_hosts
    #
    def hosts_file(nodes=nil)
      if nodes.nil?
        if @referenced_nodes && @referenced_nodes.any?
          nodes = @referenced_nodes
          nodes = nodes.merge(nodes_like_me[:services => 'mx'])  # all nodes always need to communicate with mx nodes.
        end
      end
      return {} unless nodes
      hosts = {}
      my_location = @node['location'] ? @node['location']['name'] : nil
      nodes.each_node do |node|
        hosts[node.name] = {'ip_address' => node.ip_address, 'domain_internal' => node.domain.internal, 'domain_full' => node.domain.full}
        node_location = node['location'] ? node['location']['name'] : nil
        if my_location == node_location
          if facts = @node.manager.facts[node.name]
            if facts['ec2_public_ipv4']
              hosts[node.name]['ip_address'] = facts['ec2_public_ipv4']
            end
          end
        end
        host_pub_key   = Util::read_file([:node_ssh_pub_key,node.name])
        if host_pub_key
          hosts[node.name]['host_pub_key'] = host_pub_key
        end
      end
      hosts
    end

  end
end