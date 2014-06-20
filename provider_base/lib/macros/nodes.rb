# encoding: utf-8

##
## node related macros
##

module LeapCli
  module Macro

    #
    # the list of all the nodes
    #
    def nodes
      global.nodes
    end

    #
    # grab an environment appropriate provider
    #
    def provider
      global.env(@node.environment).provider
    end

    #
    # returns a list of nodes that match the same environment
    #
    # if @node.environment is not set, we return other nodes
    # where environment is not set.
    #
    def nodes_like_me
      nodes[:environment => @node.environment]
    end

    #
    # returns a list of nodes that match the location name
    # and environment of @node.
    #
    def nodes_near_me
      if @node['location'] && @node['location']['name']
        nodes_like_me['location.name' => @node.location.name]
      else
        nodes_like_me['location' => nil]
      end
    end

    #
    #
    # picks a node out from the node list in such a way that:
    #
    # (1) which nodes picked which nodes is saved in secrets.json
    # (2) when other nodes call this macro with the same node list, they are guaranteed to get a different node
    # (3) if all the nodes in the pick_node list have been picked, remaining nodes are distributed randomly.
    #
    # if the node_list is empty, an exception is raised.
    # if node_list size is 1, then that node is returned and nothing is
    # memorized via the secrets.json file.
    #
    # `label` is needed to distinguish between pools of nodes for different purposes.
    #
    # TODO: more evenly balance after all the nodes have been picked.
    #
    def pick_node(label, node_list)
      if node_list.any?
        if node_list.size == 1
          return node_list.values.first
        else
          secrets_key = "pick_node(:#{label},#{node_list.keys.sort.join(',')})"
          secrets_value = @manager.secrets.retrieve(secrets_key, @node.environment) || {}
          secrets_value[@node.name] ||= begin
            node_to_pick = nil
            node_list.each_node do |node|
              next if secrets_value.values.include?(node.name)
              node_to_pick = node.name
            end
            node_to_pick ||= secrets_value.values.shuffle.first # all picked already, so pick a random one.
            node_to_pick
          end
          picked_node_name = secrets_value[@node.name]
          @manager.secrets.set(secrets_key, secrets_value, @node.environment)
          return node_list[picked_node_name]
        end
      else
        raise ArgumentError.new('pick_node(node_list): node_list cannot be empty')
      end
    end

  end
end