# encoding: utf-8

require 'json/pure'

if $ruby_version < [1,9]
  require 'iconv'
end

module LeapCli
  module Config

    #
    # A class to manage all the objects in all the configuration files.
    #
    class Manager

      def initialize
        @environments = {} # hash of `Environment` objects, keyed by name.
        Config::Object.send(:include, LeapCli::Macro)
      end

      ##
      ## ATTRIBUTES
      ##

      #
      # returns the Hash of the contents of facts.json
      #
      def facts
        @facts ||= begin
          content = Util.read_file(:facts)
          if !content || content.empty?
            content = "{}"
          end
          JSON.parse(content)
        rescue SyntaxError, JSON::ParserError => exc
          Util::bail! "Could not parse facts.json -- #{exc}"
        end
      end

      #
      # returns an Array of all the environments defined for this provider.
      # the returned array includes nil (for the default environment)
      #
      def environment_names
        @environment_names ||= begin
          [nil] + (env.tags.field('environment') + env.nodes.field('environment')).compact.uniq
        end
      end

      #
      # Returns the appropriate environment variable
      #
      def env(env=nil)
        @environments[env || 'default']
      end

      #
      # The default accessors
      #
      # For these defaults, use 'default' environment, or whatever
      # environment is pinned.
      #
      # I think it might be an error that these are ever used
      # and I would like to get rid of them.
      #
      def services; env(default_environment).services; end
      def tags;     env(default_environment).tags;     end
      def partials; env(default_environment).partials; end
      def provider; env(default_environment).provider; end
      def common;   env(default_environment).common;   end
      def secrets;  env(default_environment).secrets;  end
      def nodes;    env(default_environment).nodes;    end
      def template(*args)
        self.env.template(*args)
      end

      def default_environment
        LeapCli.leapfile.environment
      end

      ##
      ## IMPORT EXPORT
      ##

      def add_environment(args)
        if args[:inherit]
          parent = @environments[args.delete(:inherit)]
        else
          parent = nil
        end
        @environments[args[:name]] = Environment.new(
          self,
          args.delete(:name),
          args.delete(:dir),
          parent,
          args
        )
      end

      #
      # load .json configuration files
      #
      def load(options = {})
        @provider_dir = Path.provider

        # load base
        add_environment(name: '_base_', dir: Path.provider_base)

        # load provider
        Util::assert_files_exist!(Path.named_path(:provider_config, @provider_dir))
        add_environment(name: 'default', dir: @provider_dir,
          inherit: '_base_', no_dots: true)

        # create a special '_all_' environment, used for tracking
        # the union of all the environments
        add_environment(name: '_all_', inherit: 'default')

        # load environments
        environment_names.each do |ename|
          if ename
            LeapCli.log 3, :loading, '%s environment...' % ename
            add_environment(name: ename, dir: @provider_dir,
              inherit: 'default', scope: ename)
          end
        end

        # apply inheritance
        env.nodes.each do |name, node|
          Util::assert! name =~ /^[0-9a-z-]+$/, "Illegal character(s) used in node name '#{name}'"
          env.nodes[name] = apply_inheritance(node)
        end

        # do some node-list post-processing
        cleanup_node_lists(options)

        # apply control files
        env.nodes.each do |name, node|
          control_files(node).each do |file|
            begin
              node.eval_file file
            rescue ConfigError => exc
              if options[:continue_on_error]
                exc.log
              else
                raise exc
              end
            end
          end
        end
      end

      #
      # save compiled hiera .yaml files
      #
      # if a node_list is specified, only update those .yaml files.
      # otherwise, update all files, destroying files that are no longer used.
      #
      def export_nodes(node_list=nil)
        updated_hiera = []
        updated_files = []
        existing_hiera = nil
        existing_files = nil

        unless node_list
          node_list = env.nodes
          existing_hiera = Dir.glob(Path.named_path([:hiera, '*'], @provider_dir))
          existing_files = Dir.glob(Path.named_path([:node_files_dir, '*'], @provider_dir))
        end

        node_list.each_node do |node|
          filepath = Path.named_path([:node_files_dir, node.name], @provider_dir)
          hierapath = Path.named_path([:hiera, node.name], @provider_dir)
          Util::write_file!(hierapath, node.dump_yaml)
          updated_files << filepath
          updated_hiera << hierapath
        end

        if @disabled_nodes
          # make disabled nodes appear as if they are still active
          @disabled_nodes.each_node do |node|
            updated_files << Path.named_path([:node_files_dir, node.name], @provider_dir)
            updated_hiera << Path.named_path([:hiera, node.name], @provider_dir)
          end
        end

        # remove files that are no longer needed
        if existing_hiera
          (existing_hiera - updated_hiera).each do |filepath|
            Util::remove_file!(filepath)
          end
        end
        if existing_files
          (existing_files - updated_files).each do |filepath|
            Util::remove_directory!(filepath)
          end
        end
      end

      def export_secrets(clean_unused_secrets = false)
        if env.secrets.any?
          Util.write_file!([:secrets_config, @provider_dir], env.secrets.dump_json(clean_unused_secrets) + "\n")
        end
      end

      ##
      ## FILTERING
      ##

      #
      # returns a node list consisting only of nodes that satisfy the filter criteria.
      #
      # filter: condition [condition] [condition] [+condition]
      # condition: [node_name | service_name | tag_name | environment_name]
      #
      # if conditions is prefixed with +, then it works like an AND. Otherwise, it works like an OR.
      #
      # args:
      # filter -- array of filter terms, one per item
      #
      # options:
      # :local -- if :local is false and the filter is empty, then local nodes are excluded.
      # :nopin -- if true, ignore environment pinning
      #
      def filter(filters=nil, options={})
        Filter.new(filters, options, self).nodes()
      end

      #
      # same as filter(), but exits if there is no matching nodes
      #
      def filter!(filters, options={})
        node_list = filter(filters, options)
        Util::assert! node_list.any?, "Could not match any nodes from '#{filters.join ' '}'"
        return node_list
      end

      #
      # returns a single Config::Object that corresponds to a Node.
      #
      def node(name)
        if name =~ /\./
          # probably got a fqdn, since periods are not allowed in node names.
          # so, take the part before the first period as the node name
          name = name.split('.').first
        end
        env.nodes[name]
      end

      #
      # returns a single node that is disabled
      #
      def disabled_node(name)
        @disabled_nodes[name]
      end

      #
      # yields each node, in sorted order
      #
      def each_node(&block)
        env.nodes.each_node(&block)
      end

      def reload_node!(node)
        env.nodes[node.name] = apply_inheritance!(node)
      end

      ##
      ## CONNECTIONS
      ##

      class ConnectionList < Array
        def add(data={})
          self << {
            "from" => data[:from],
            "to" => data[:to],
            "port" => data[:port]
          }
        end
      end

      def connections
        @connections ||= ConnectionList.new
      end

      ##
      ## PRIVATE
      ##

      private

      #
      # makes a node inherit options from appropriate the common, service, and tag json files.
      #
      def apply_inheritance(node, throw_exceptions=false)
        new_node = Config::Node.new(nil)
        node_env = guess_node_env(node)
        new_node.set_environment(node_env, new_node)

        # inherit from common
        new_node.deep_merge!(node_env.common)

        # inherit from services
        if node['services']
          node['services'].to_a.each do |node_service|
            service = node_env.services[node_service]
            if service.nil?
              msg = 'in node "%s": the service "%s" does not exist.' % [node['name'], node_service]
              LeapCli.log 0, :error, msg
              raise LeapCli::ConfigError.new(node, "error " + msg) if throw_exceptions
            else
              new_node.deep_merge!(service)
            end
          end
        end

        # inherit from tags
        if node.vagrant?
          node['tags'] = (node['tags'] || []).to_a + ['local']
        end
        if node['tags']
          node['tags'].to_a.each do |node_tag|
            tag = node_env.tags[node_tag]
            if tag.nil?
              msg = 'in node "%s": the tag "%s" does not exist.' % [node['name'], node_tag]
              log 0, :error, msg
              raise LeapCli::ConfigError.new(node, "error " + msg) if throw_exceptions
            else
              new_node.deep_merge!(tag)
            end
          end
        end

        # inherit from node
        new_node.deep_merge!(node)
        return new_node
      end

      def apply_inheritance!(node)
        apply_inheritance(node, true)
      end

      #
      # Guess the environment of the node from the tag names.
      #
      # Technically, this is wrong: a tag that sets the environment might not be
      # named the same as the environment. This code assumes that it is.
      #
      # Unfortunately, it is a chicken and egg problem. We need to know the nodes
      # likely environment in order to apply the inheritance that will actually
      # determine the node's properties.
      #
      def guess_node_env(node)
        if node.vagrant?
          return self.env("local")
        else
          environment = self.env(default_environment)
          if node['tags']
            node['tags'].to_a.each do |tag|
              if self.environment_names.include?(tag)
                environment = self.env(tag)
              end
            end
          end
          return environment
        end
      end

      #
      # does some final clean at the end of loading nodes.
      # this includes removing disabled nodes, and populating
      # the services[x].node_list and tags[x].node_list
      #
      def cleanup_node_lists(options)
        @disabled_nodes = Config::ObjectList.new
        env.nodes.each do |name, node|
          if node.enabled || options[:include_disabled]
            if node['services']
              node['services'].to_a.each do |node_service|
                env(node.environment).services[node_service].node_list.add(node.name, node)
                env('_all_').services[node_service].node_list.add(node.name, node)
              end
            end
            if node['tags']
              node['tags'].to_a.each do |node_tag|
                env(node.environment).tags[node_tag].node_list.add(node.name, node)
                env('_all_').tags[node_tag].node_list.add(node.name, node)
              end
            end
            if node.name == 'default' || environment_names.include?(node.name)
              LeapCli::Util.bail! do
                LeapCli.log :error, "The node name '#{node.name}' is invalid, because there is an environment with that same name."
              end
            end
          elsif !options[:include_disabled]
            LeapCli.log 2, :skipping, "disabled node #{name}."
            env.nodes.delete(name)
            @disabled_nodes[name] = node
          end
        end
      end

      #
      # returns a list of 'control' files for this node.
      # a control file is like a service or a tag JSON file, but it contains
      # raw ruby code that gets evaluated in the context of the node.
      # Yes, this entirely breaks our functional programming model
      # for JSON generation.
      #
      def control_files(node)
        files = []
        [Path.provider_base, @provider_dir].each do |provider_dir|
          [['services', :service_config], ['tags', :tag_config]].each do |attribute, path_sym|
            node[attribute].each do |attr_value|
              path = Path.named_path([path_sym, "#{attr_value}.rb"], provider_dir).sub(/\.json$/,'')
              if File.exist?(path)
                files << path
              end
            end
          end
        end
        return files
      end

    end
  end
end
