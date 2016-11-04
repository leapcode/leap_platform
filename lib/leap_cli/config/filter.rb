#
# Many leap_cli commands accept a list of filters to select a subset of nodes for the command to
# be applied to. This class is a helper for manager to run these filters.
#
# Classes other than Manager should not use this class.
#
# Filter rules:
#
# * A filter consists of a list of tokens
# * A token may be a service name, tag name, environment name, or node name.
# * Each token may be optionally prefixed with a plus sign.
# * Multiple tokens with a plus are treated as an OR condition,
#   but treated as an AND condition with the plus sign.
#
# For example
#
# * openvpn +development => all nodes with service 'openvpn' AND environment 'development'
# * openvpn seattle => all nodes with service 'openvpn' OR tag 'seattle'.
#
# There can only be one environment specified. Typically, there are also tags
# for each environment name. These name are treated as environments, not tags.
#
module LeapCli
  module Config
    class Filter

      #
      # filter -- array of strings, each one a filter
      # options -- hash, possible keys include
      #   :nopin -- disregard environment pinning
      #   :local -- if false, disallow local nodes
      #   :warning -- if false, don't print a warning when no nodes are found.
      #
      # A nil value in the filters array indicates
      # the default environment. This is in order to support
      # calls like `manager.filter(environments)`
      #
      def initialize(filters, options, manager)
        @filters = filters.nil? ? [] : filters.dup
        @environments = []
        @options = options
        @manager = manager

        # split filters by pulling out items that happen
        # to be environment names.
        if LeapCli.leapfile.environment.nil? || @options[:nopin]
          @environments = []
        else
          @environments = [LeapCli.leapfile.environment]
        end
        @filters.select! do |filter|
          if filter.nil?
            @environments << nil unless @environments.include?(nil)
            false
          else
            filter_text = filter.sub(/^\+/,'')
            if is_environment?(filter_text)
              if filter_text == LeapCli.leapfile.environment
                # silently ignore already pinned environments
              elsif (filter =~ /^\+/ || @filters.first == filter) && !@environments.empty?
                LeapCli::Util.bail! do
                  LeapCli.log "Environments are exclusive: no node is in two environments." do
                    LeapCli.log "Tried to filter on '#{@environments.join('\' AND \'')}' AND '#{filter_text}'"
                  end
                end
              else
                @environments << filter_text
              end
              false
            else
              true
            end
          end
        end

        # don't let the first filter have a + prefix
        if @filters[0] =~ /^\+/
          @filters[0] = @filters[0][1..-1]
        end
      end

      # actually run the filter, returns a filtered list of nodes
      def nodes()
        if @filters.empty?
          return nodes_for_empty_filter
        else
          return nodes_for_filter
        end
      end

      private

      def nodes_for_empty_filter
        node_list = @manager.nodes
        if @environments.any?
          node_list = node_list[ @environments.collect{|e|[:environment, env_to_filter(e)]} ]
        end
        if @options[:local] === false
          node_list = node_list[:environment => '!local']
        end
        if @options[:disabled] === false
          node_list = node_list[:environment => '!disabled']
        end
        node_list
      end

      def nodes_for_filter
        node_list = Config::ObjectList.new
        @filters.each do |filter|
          if filter =~ /^\+/
            keep_list = nodes_for_name(filter[1..-1])
            node_list.delete_if do |name, node|
              if keep_list[name]
                false
              else
                true
              end
            end
          else
            node_list.merge!(nodes_for_name(filter))
          end
        end
        node_list
      end

      private

      #
      # returns a set of nodes corresponding to a single name,
      # where name could be a node name, service name, or tag name.
      #
      # For services and tags, we only include nodes for the
      # environments that are active
      #
      def nodes_for_name(name)
        if node = @manager.nodes[name]
          return Config::ObjectList.new(node)
        elsif @environments.empty?
          if @manager.services[name]
            return @manager.env('_all_').services[name].node_list
          elsif @manager.tags[name]
            return @manager.env('_all_').tags[name].node_list
          elsif @options[:warning] != false
            LeapCli.log :warning, "filter '#{name}' does not match any node names, tags, services, or environments."
            return Config::ObjectList.new
          else
            return Config::ObjectList.new
          end
        else
          node_list = Config::ObjectList.new
          if @manager.services[name]
            @environments.each do |env|
              node_list.merge!(@manager.env(env).services[name].node_list)
            end
          elsif @manager.tags[name]
            @environments.each do |env|
              node_list.merge!(@manager.env(env).tags[name].node_list)
            end
          elsif @options[:warning] != false
            LeapCli.log :warning, "filter '#{name}' does not match any node names, tags, services, or environments."
          end
          return node_list
        end
      end

      #
      # when pinning, we use the name 'default' to specify nodes
      # without an environment set, but when filtering, we need to filter
      # on :environment => nil.
      #
      def env_to_filter(environment)
        environment == 'default' ? nil : environment
      end

      def is_environment?(text)
        text == 'default' || @manager.environment_names.include?(text)
      end

    end
  end
end
