##
## STUNNEL
##

#
# About stunnel
# --------------------------
#
# The network looks like this:
#
#   From the client's perspective:
#
#   |------- stunnel client --------------|    |---------- stunnel server -----------------------|
#    consumer app -> localhost:accept_port  ->  connect:connect_port -> ??
#
#   From the server's perspective:
#
#   |------- stunnel client --------------|    |---------- stunnel server -----------------------|
#                                       ??  ->  *:accept_port -> localhost:connect_port -> service
#

module LeapCli
  module Macro

    #
    # stunnel configuration for the client side.
    #
    # +node_list+ is a ObjectList of nodes running stunnel servers.
    #
    # +port+ is the real port of the ultimate service running on the servers
    # that the client wants to connect to.
    #
    # * accept_port is the port on localhost to which local clients
    #   can connect. it is auto generated serially.
    #
    # * connect_port is the port on the stunnel server to connect to.
    #   it is auto generated from the +port+ argument.
    #
    # generates an entry appropriate to be passed directly to
    # create_resources(stunnel::service, hiera('..'), defaults)
    #
    # local ports are automatically generated, starting at 4000
    # and incrementing in sorted order (by node name).
    #
    def stunnel_client(node_list, port, options={})
      @next_stunnel_port ||= 4000
      node_list = listify(node_list)
      hostnames(node_list) # record the hosts
      result = Config::ObjectList.new
      node_list.each_node do |node|
        if node.name != self.name || options[:include_self]
          result["#{node.name}_#{port}"] = Config::Object[
            'accept_port', @next_stunnel_port,
            'connect', node.domain.internal,
            'connect_port', stunnel_port(port),
            'original_port', port
          ]
          @next_stunnel_port += 1
        end
      end
      result
    end

    #
    # generates a stunnel server entry.
    #
    # +port+ is the real port targeted service.
    #
    # * `accept_port` is the publicly bound port
    # * `connect_port` is the port that the local service is running on.
    #
    def stunnel_server(port)
      {
        "accept_port" => stunnel_port(port),
        "connect_port" => port
      }
    end

    private

    #
    # maps a real port to a stunnel port (used as the connect_port in the client config
    # and the accept_port in the server config)
    #
    def stunnel_port(port)
      port = port.to_i
      if port < 50000
        return port + 10000
      else
        return port - 10000
      end
    end

  end
end