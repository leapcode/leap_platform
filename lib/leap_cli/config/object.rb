# encoding: utf-8

require 'erb'
require 'json/pure'  # pure ruby implementation is required for our sorted trick to work.

if $ruby_version < [1,9]
  $KCODE = 'UTF8'
end
require 'ya2yaml' # pure ruby yaml

module LeapCli
  module Config

    #
    # This class represents the configuration for a single node, service, or tag.
    # Also, all the nested hashes are also of this type.
    #
    # It is called 'object' because it corresponds to an Object in JSON.
    #
    class Object < Hash

      attr_reader :env
      attr_reader :node

      def initialize(environment=nil, node=nil)
        raise ArgumentError unless environment.nil? || environment.is_a?(Config::Environment)
        @env = environment
        # an object that is a node as @node equal to self, otherwise all the
        # child objects point back to the top level node.
        @node = node || self
      end

      def manager
        @env.manager
      end

      #
      # TODO: deprecate node.global()
      #
      def global
        @env
      end

      def environment=(e)
        self.store('environment', e)
      end

      def environment
        self['environment']
      end

      def duplicate(env)
        new_object = self.deep_dup
        new_object.set_environment(env, new_object)
      end

      #
      # export YAML
      #
      # We use pure ruby yaml exporter ya2yaml instead of SYCK or PSYCH because it
      # allows us greater compatibility regardless of installed ruby version and
      # greater control over how the yaml is exported (sorted keys, in particular).
      #
      def dump_yaml
        evaluate(@node)
        sorted_ya2yaml(:syck_compatible => true)
      end

      #
      # export JSON
      #
      def dump_json(options={})
        evaluate(@node)
        if options[:format] == :compact
          return self.to_json
        else
          excluded = {}
          if options[:exclude]
            options[:exclude].each do |key|
              excluded[key] = self[key]
              self.delete(key)
            end
          end
          json_str = JSON.sorted_generate(self)
          if excluded.any?
            self.merge!(excluded)
          end
          return json_str
        end
      end

      def evaluate(context=@node)
        evaluate_everything(context)
        late_evaluate_everything(context)
      end

      ##
      ## FETCHING VALUES
      ##

      def [](key)
        get(key)
      end

      # Overrride some default methods in Hash that are likely to
      # be used as attributes.
      alias_method :hkey, :key
      def key; get('key'); end

      #
      # make hash addressable like an object (e.g. obj['name'] available as obj.name)
      #
      def method_missing(method, *args, &block)
        get!(method)
      end

      def get(key)
        begin
          get!(key)
        rescue NoMethodError
          nil
        end
      end

      # override behavior of #default() from Hash
      def default
        get!('default')
      end

      #
      # Like a normal Hash#[], except:
      #
      # (1) lazily eval dynamic values when we encounter them. (i.e. strings that start with "= ")
      #
      # (2) support for nested references in a single string (e.g. ['a.b'] is the same as ['a']['b'])
      #     the dot path is always absolute, starting at the top-most object.
      #
      def get!(key)
        key = key.to_s
        if self.has_key?(key)
          fetch_value(key)
        elsif key =~ /\./
          # for keys with with '.' in them, we start from the root object (@node).
          keys = key.split('.')
          value = self.get!(keys.first)
          if value.is_a? Config::Object
            value.get!(keys[1..-1].join('.'))
          else
            value
          end
        else
          raise NoMethodError.new(key, "No method '#{key}' for #{self.class}")
        end
      end

      ##
      ## COPYING
      ##

      #
      # A deep (recursive) merge with another Config::Object.
      #
      # If prefer_self is set to true, the value from self will be picked when there is a conflict
      # that cannot be merged.
      #
      # Merging rules:
      #
      # - If a value is a hash, we recursively merge it.
      # - If the value is simple, like a string, the new one overwrites the value.
      # - If the value is an array:
      #   - If both old and new values are arrays, the new one replaces the old.
      #   - If one of the values is simple but the other is an array, the simple is added to the array.
      #
      def deep_merge!(object, prefer_self=false)
        object.each do |key,new_value|
          if self.has_key?('+'+key)
            mode = :add
            old_value = self.fetch '+'+key, nil
            self.delete('+'+key)
          elsif self.has_key?('-'+key)
            mode = :subtract
            old_value = self.fetch '-'+key, nil
            self.delete('-'+key)
          elsif self.has_key?('!'+key)
            mode = :replace
            old_value = self.fetch '!'+key, nil
            self.delete('!'+key)
          else
            mode = :normal
            old_value = self.fetch key, nil
          end

          # clean up boolean
          new_value = true  if new_value == "true"
          new_value = false if new_value == "false"
          old_value = true  if old_value == "true"
          old_value = false if old_value == "false"

          # force replace?
          if mode == :replace && prefer_self
            value = old_value

          # merge hashes
          elsif old_value.is_a?(Hash) || new_value.is_a?(Hash)
            value = Config::Object.new(@env, @node)
            old_value.is_a?(Hash) ? value.deep_merge!(old_value) : (value[key] = old_value if !old_value.nil?)
            new_value.is_a?(Hash) ? value.deep_merge!(new_value, prefer_self) : (value[key] = new_value if !new_value.nil?)

          # merge nil
          elsif new_value.nil?
            value = old_value
          elsif old_value.nil?
            value = new_value

          # merge arrays when one value is not an array
          elsif old_value.is_a?(Array) && !new_value.is_a?(Array)
            (value = (old_value.dup << new_value).compact.uniq).delete('REQUIRED')
          elsif new_value.is_a?(Array) && !old_value.is_a?(Array)
            (value = (new_value.dup << old_value).compact.uniq).delete('REQUIRED')

          # merge two arrays
          elsif old_value.is_a?(Array) && new_value.is_a?(Array)
            if mode == :add
              value = (old_value + new_value).sort.uniq
            elsif mode == :subtract
              value = new_value - old_value
            elsif prefer_self
              value = old_value
            else
              value = new_value
            end

          # catch errors
          elsif type_mismatch?(old_value, new_value)
            raise 'Type mismatch. Cannot merge %s (%s) with %s (%s). Key is "%s", name is "%s".' % [
              old_value.inspect, old_value.class,
              new_value.inspect, new_value.class,
              key, self.class
            ]

          # merge simple strings & numbers
          else
            if prefer_self
              value = old_value
            else
              value = new_value
            end
          end

          # save value
          self[key] = value
        end
        self
      end

      def set_environment(env, node)
        @env = env
        @node = node
        self.each do |key, value|
          if value.is_a?(Config::Object)
            value.set_environment(env, node)
          end
        end
      end

      #
      # like a reverse deep merge
      # (self takes precedence)
      #
      def inherit_from!(object)
        self.deep_merge!(object, true)
      end

      #
      # Make a copy of ourselves, except only including the specified keys.
      #
      # Also, the result is flattened to a single hash, so a key of 'a.b' becomes 'a_b'
      #
      def pick(*keys)
        keys.map(&:to_s).inject(self.class.new(@manager)) do |hsh, key|
          value = self.get(key)
          if !value.nil?
            hsh[key.gsub('.','_')] = value
          end
          hsh
        end
      end

      def eval_file(filename)
        evaluate_ruby(filename, File.read(filename))
      end

      protected

      #
      # walks the object tree, eval'ing all the attributes that are dynamic ruby (e.g. value starts with '= ')
      #
      def evaluate_everything(context)
        keys.each do |key|
          obj = fetch_value(key, context)
          if is_required_value_not_set?(obj)
            Util::log 0, :warning, "required property \"#{key}\" is not set in node \"#{node.name}\"."
          elsif obj.is_a? Config::Object
            obj.evaluate_everything(context)
          end
        end
      end

      #
      # some keys need to be evaluated 'late', after all the other keys have been evaluated.
      #
      def late_evaluate_everything(context)
        if @late_eval_list
          @late_eval_list.each do |key, value|
            self[key] = context.evaluate_ruby(key, value)
            if is_required_value_not_set?(self[key])
              Util::log 0, :warning, "required property \"#{key}\" is not set in node \"#{node.name}\"."
            end
          end
        end
        values.each do |obj|
          if obj.is_a? Config::Object
            obj.late_evaluate_everything(context)
          end
        end
      end

      #
      # evaluates the string `value` as ruby in the context of self.
      # (`key` is just passed for debugging purposes)
      #
      def evaluate_ruby(key, value)
        self.instance_eval(value, key, 1)
      rescue ConfigError => exc
        raise exc # pass through
      rescue SystemStackError => exc
        Util::log 0, :error, "while evaluating node '#{self.name}'"
        Util::log 0, "offending key: #{key}", :indent => 1
        Util::log 0, "offending string: #{value}", :indent => 1
        Util::log 0, "STACK OVERFLOW, BAILING OUT. There must be an eval loop of death (variables with circular dependencies).", :indent => 1
        raise SystemExit.new(1)
      rescue FileMissing => exc
        Util::bail! do
          if exc.options[:missing]
            Util::log :missing, exc.options[:missing].gsub('$node', self.name).gsub('$file', exc.path)
          else
            Util::log :error, "while evaluating node '#{self.name}'"
            Util::log "offending key: #{key}", :indent => 1
            Util::log "offending string: #{value}", :indent => 1
            Util::log "error message: no file '#{exc}'", :indent => 1
          end
          raise exc if DEBUG
        end
      rescue AssertionFailed => exc
        Util.bail! do
          Util::log :failed, "assertion while evaluating node '#{self.name}'"
          Util::log 'assertion: %s' % exc.assertion, :indent => 1
          Util::log "offending key: #{key}", :indent => 1
          raise exc if DEBUG
        end
      rescue SyntaxError, StandardError => exc
        Util::bail! do
          Util::log :error, "while evaluating node '#{self.name}'"
          Util::log "offending key: #{key}", :indent => 1
          Util::log "offending string: #{value}", :indent => 1
          Util::log "error message: #{exc.inspect}", :indent => 1
          raise exc if DEBUG
        end
      end

      private

      #
      # fetches the value for the key, evaluating the value as ruby if it begins with '='
      #
      def fetch_value(key, context=@node)
        value = fetch(key, nil)
        if value.is_a?(String) && value =~ /^=/
          if value =~ /^=> (.*)$/
            value = evaluate_later(key, $1)
          elsif value =~ /^= (.*)$/
            value = context.evaluate_ruby(key, $1)
          end
          self[key] = value
        end
        return value
      end

      def evaluate_later(key, value)
        @late_eval_list ||= []
        @late_eval_list << [key, value]
        '<evaluate later>'
      end

      #
      # when merging, we raise an error if this method returns true for the two values.
      #
      def type_mismatch?(old_value, new_value)
        if old_value.is_a?(Boolean) && new_value.is_a?(Boolean)
          # note: FalseClass and TrueClass are different classes
          # so we can't do old_value.class == new_value.class
          return false
        elsif old_value.is_a?(String) && old_value =~ /^=/
          # pass through macros, since we don't know what the type will eventually be.
          return false
        elsif new_value.is_a?(String) && new_value =~ /^=/
          return false
        elsif old_value.class == new_value.class
          return false
        else
          return true
        end
      end

      #
      # returns true if the value has not been changed and the default is "REQUIRED"
      #
      def is_required_value_not_set?(value)
        if value.is_a? Array
          value == ["REQUIRED"]
        else
          value == "REQUIRED"
        end
      end

    end # class
  end # module
end # module