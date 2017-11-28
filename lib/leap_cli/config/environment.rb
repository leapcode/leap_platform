#
# All configurations files can be isolated into separate environments.
#
# Each config json in each environment inherits from the default environment,
# which in term inherits from the "_base_" environment:
#
# _base_             -- base provider in leap_platform
# '- default         -- environment in provider dir when no env is set
#    '- production   -- example environment
#

module LeapCli; module Config

  class Environment
    # the String name of the environment
    attr_accessor :name

    # the shared Manager object
    attr_accessor :manager

    # hashes of {name => Config::Object}
    attr_accessor :services, :tags, :partials

    # a Config::Provider
    attr_accessor :provider

    # a Config::Object
    attr_accessor :common

    # shared, non-inheritable
    def nodes; @@nodes; end
    def secrets; @@secrets; end
    def cloud; @@cloud; end

    def initialize(manager, name, search_dir, parent, options={})
      @@nodes ||= nil
      @@secrets ||= nil
      @@cloud ||= nil

      @manager = manager
      @name    = name

      load_provider_files(search_dir, options)

      if parent
        @services.inherit_from! parent.services, self
            @tags.inherit_from! parent.tags    , self
        @partials.inherit_from! parent.partials, self
          @common.inherit_from! parent.common
        @provider.inherit_from! parent.provider
      end

      if @provider
        @provider.set_env(name)
        @provider.validate!
      end
    end

    def load_provider_files(search_dir, options)
      #
      # load empty environment if search_dir doesn't exist
      #
      if search_dir.nil? || !Dir.exist?(search_dir)
        @services = Config::ObjectList.new
        @tags     = Config::ObjectList.new
        @partials = Config::ObjectList.new
        @provider = Config::Provider.new
        @common   = Config::Object.new
        @cloud    = Config::Cloud.new
        return
      end

      #
      # inheritable
      #
      if options[:scope]
        scope = options[:scope]
        @services = load_all_json(Path.named_path([:service_env_config, '*', scope],  search_dir), Config::Tag, options)
        @tags     = load_all_json(Path.named_path([:tag_env_config, '*', scope],      search_dir), Config::Tag, options)
        @partials = load_all_json(Path.named_path([:service_env_config, '_*', scope], search_dir), Config::Tag, options)
        @provider = load_json(    Path.named_path([:provider_env_config, scope],      search_dir), Config::Provider, options)
        @common   = load_json(    Path.named_path([:common_env_config, scope],        search_dir), Config::Object, options)
      else
        @services = load_all_json(Path.named_path([:service_config, '*'],  search_dir), Config::Tag, options)
        @tags     = load_all_json(Path.named_path([:tag_config, '*'],      search_dir), Config::Tag, options)
        @partials = load_all_json(Path.named_path([:service_config, '_*'], search_dir), Config::Tag, options)
        @provider = load_json(    Path.named_path(:provider_config,        search_dir), Config::Provider, options)
        @common   = load_json(    Path.named_path(:common_config,          search_dir), Config::Object, options)
      end

      # remove 'name' from partials, since partials get merged with nodes
      @partials.values.each {|partial| partial.delete('name'); }

      #
      # shared
      #
      # shared configs are also non-inheritable
      # load the first ones we find, and only those.
      #
      if @@nodes.nil? || @@nodes.empty?
        @@nodes = load_all_json(Path.named_path([:node_config, '*'], search_dir), Config::Node, options)
      end
      if @@secrets.nil? || @@secrets.empty?
        @@secrets = load_json(Path.named_path(:secrets_config, search_dir), Config::Secrets, options)
      end
      if @@cloud.nil? || @@cloud.empty?
        @@cloud = load_json(Path.named_path(:cloud_config, search_dir), Config::Cloud)
      end
    end

    #
    # Loads a json template file as a Hash (used only when creating a new node .json
    # file for the first time).
    #
    def template(template)
      path = Path.named_path([:template_config, template], Path.provider_base)
      if File.exist?(path)
        return load_json(path, Config::Object)
      else
        return nil
      end
    end

    #
    # Alters the node's json config file. As a side effect, all comments get
    # moved to the top of the file.
    #
    # NOTE: This does a shallow merge! In other words, a call like this...
    #
    #     update_node_json(node, {"webapp" => {"domain" => "example.org"})
    #
    # ...is probably not what you want, because it will entirely remove all
    # existing entries under "webapp".
    #
    def update_node_json(node, new_values, options=nil)
      node_json_path = Path.named_path([:node_config, node.name])
      comments       = read_comments(node_json_path)
      old_data       = load_json(node_json_path, Config::Node)
      options && options[:remove] && options[:remove].each do |key|
        old_data.delete(key)
      end
      new_data       = old_data.merge(new_values)
      new_contents   = [comments, JSON.sorted_generate(new_data), "\n"].join
      Util::write_file! node_json_path, new_contents
    end

    private

    def load_all_json(pattern, object_class, options={})
      results = Config::ObjectList.new
      Dir.glob(pattern).each do |filename|
        next if options[:no_dots] && File.basename(filename) !~ /^[^\.]*\.json$/
        obj = load_json(filename, object_class)
        if obj
          name = File.basename(filename).force_encoding('utf-8').sub(/^([^\.]+).*\.json$/,'\1')
          obj['name'] ||= name
          if options[:env]
            obj.environment = options[:env]
          end
          results[name] = obj
        end
      end
      results
    end

    def read_comments(filename)
      buffer = StringIO.new
      File.open(filename, "rb", :encoding => 'UTF-8') do |f|
        while (line = f.gets)
          next unless line =~ /^\s*\/\//
          buffer << line
        end
      end
      return buffer.string.force_encoding('utf-8')
    end

    def load_json(filename, object_class, options={})
      if !File.exist?(filename)
        return object_class.new(self)
      end

      Util::log :loading, filename, 3

      #
      # Read a JSON file, strip out comments.
      #
      # UTF8 is the default encoding for JSON, but others are allowed:
      # https://www.ietf.org/rfc/rfc4627.txt
      #
      buffer = StringIO.new
      File.open(filename, "rb", :encoding => 'UTF-8') do |f|
        while (line = f.gets)
          next if line =~ /^\s*\/\//
          buffer << line
        end
      end

      #
      # force UTF-8
      #
      if $ruby_version >= [1,9]
        string = buffer.string.force_encoding('utf-8')
      else
        string = Iconv.conv("UTF-8//IGNORE", "UTF-8", buffer.string)
      end

      # parse json
      begin
        hash = JSON.parse(string, :object_class => Hash, :array_class => Array) || {}
      rescue SyntaxError, JSON::ParserError => exc
        Util::log 0, :error, 'in file "%s":' % filename
        Util::log 0, exc.to_s, :indent => 1
        return nil
      end
      object = object_class.new(self)
      object.deep_merge!(hash)
      return object
    end

  end # end Environment

end; end