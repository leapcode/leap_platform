# encoding: utf-8

##
## HAPROXY
##

module LeapCli
  module Macro

    #
    # creates a hash suitable for configuring haproxy. the key is the node name of the server we are proxying to.
    #
    # * node_list - a hash of nodes for the haproxy servers
    # * stunnel_client - contains the mappings to local ports for each server node.
    # * non_stunnel_port - in case self is included in node_list, the port to connect to.
    #
    # 1000 weight is used for nodes in the same location.
    # 100 otherwise.
    #
    def haproxy_servers(node_list, stunnel_clients, non_stunnel_port=nil)
      default_weight = 10
      local_weight = 100

      # record the hosts_file
      hostnames(node_list)

      # create a simple map for node name -> local stunnel accept port
      accept_ports = stunnel_clients.inject({}) do |hsh, stunnel_entry|
        name = stunnel_entry.first.sub(/_[0-9]+$/, '')
        hsh[name] = stunnel_entry.last['accept_port']
        hsh
      end

      # if one the nodes in the node list is ourself, then there will not be a stunnel to it,
      # but we need to include it anyway in the haproxy config.
      if node_list[self.name] && non_stunnel_port
        accept_ports[self.name] = non_stunnel_port
      end

      # create the first pass of the servers hash
      servers = node_list.values.inject(Config::ObjectList.new) do |hsh, node|
        # make sure we have a port to talk to
        unless accept_ports[node.name]
          error "haproxy needs a local port to talk to when connecting to #{node.name}"
        end
        weight = default_weight
        try {
          weight = local_weight if self.location.name == node.location.name
        }
        hsh[node.name] = Config::Object[
          'backup', false,
          'host', 'localhost',
          'port', accept_ports[node.name],
          'weight', weight
        ]
        if node.services.include?('couchdb')
          hsh[node.name]['writable'] = node.couch.mode != 'mirror'
        end
        hsh
      end

      # if there are some local servers, make the others backup
      if servers.detect{|k,v| v.weight == local_weight}
        servers.each do |k,server|
          server['backup'] = server['weight'] == default_weight
        end
      end

      return servers
    end

  end
end
