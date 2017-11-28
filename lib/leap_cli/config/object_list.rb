require 'tsort'

module LeapCli
  module Config
    #
    # A list of Config::Object instances (internally stored as a hash)
    #
    class ObjectList < Hash
      include TSort

      def initialize(config=nil)
        if config
          self.add(config['name'], config)
        end
      end

      #
      # If the key is a string, the Config::Object it references is returned.
      #
      # If the key is a hash, we treat it as a condition and filter all the Config::Objects using the condition.
      # A new ObjectList is returned.
      #
      # Examples:
      #
      # nodes['vpn1']
      #   node named 'vpn1'
      #
      # nodes[:public_dns => true]
      #   all nodes with public dns
      #
      # nodes[:services => 'openvpn', 'location.country_code' => 'US']
      #   all nodes with services containing 'openvpn' OR country code of US
      #
      # Sometimes, you want to do an OR condition with multiple conditions
      # for the same field. Since hash keys must be unique, you can use
      # an array representation instead:
      #
      # nodes[[:services, 'openvpn'], [:services, 'tor']]
      #   nodes with openvpn OR tor service
      #
      # nodes[:services => 'openvpn'][:tags => 'production']
      #   nodes with openvpn AND are production
      #
      def [](key)
        if key.is_a?(Hash) || key.is_a?(Array)
          filter(key)
        else
          super key.to_s
        end
      end

      def first
        ObjectList.new(self.values.first)
      end

      def exclude(node)
        list = self.dup
        list.delete(node.name)
        return list
      end

      def each_node(&block)
        self.keys.sort.each do |node_name|
          yield self[node_name]
        end
      end

      #
      # filters this object list, producing a new list.
      # filter is an array or a hash. see []
      #
      def filter(filter)
        results = Config::ObjectList.new
        filter.each do |field, match_value|
          field = field.is_a?(Symbol) ? field.to_s : field
          match_value = match_value.is_a?(Symbol) ? match_value.to_s : match_value
          if match_value.is_a?(String) && match_value =~ /^!/
            operator = :not_equal
            match_value = match_value.sub(/^!/, '')
          else
            operator = :equal
          end
          each do |name, config|
            value = config[field]
            if value.is_a? Array
              if operator == :equal && value.include?(match_value)
                results[name] = config
              elsif operator == :not_equal && !value.include?(match_value)
                results[name] = config
              end
            elsif match_value.is_a? Array
              if operator == :equal && match_value.include?(value)
                results[name] = config
              elsif operator == :not_equal && !match_value.include?(value)
                results[name] = config
              end
            else
              if operator == :equal && value == match_value
                results[name] = config
              elsif operator == :not_equal && value != match_value
                results[name] = config
              end
            end
          end
        end
        results
      end

      def add(name, object)
        self[name] = object
      end

      #
      # converts the hash of configs into an array of hashes, with ONLY the specified fields
      #
      def fields(*fields)
        result = []
        keys.sort.each do |name|
          result << self[name].pick(*fields)
        end
        result
      end

      #
      # like fields(), but returns an array of values instead of an array of hashes.
      #
      def field(field)
        field = field.to_s
        result = []
        keys.sort.each do |name|
          result << self[name].get(field)
        end
        result
      end

      #
      # pick_fields(field1, field2, ...)
      #
      # generates a Hash from the object list, but with only the fields that are picked.
      #
      # If there are more than one field, then the result is a Hash of Hashes.
      # If there is just one field, it is a simple map to the value.
      #
      # For example:
      #
      #   "neighbors" = "= nodes_like_me[:services => :couchdb].pick_fields('domain.full', 'ip_address')"
      #
      # generates this:
      #
      #   neighbors:
      #     couch1:
      #       domain_full: couch1.bitmask.net
      #       ip_address: "10.5.5.44"
      #     couch2:
      #       domain_full: couch2.bitmask.net
      #       ip_address: "10.5.5.52"
      #
      # But this:
      #
      #   "neighbors": "= nodes_like_me[:services => :couchdb].pick_fields('domain.full')"
      #
      # will generate this:
      #
      #   neighbors:
      #     couch1: couch1.bitmask.net
      #     couch2: couch2.bitmask.net
      #
      def pick_fields(*fields)
        self.values.inject({}) do |hsh, node|
          value = self[node.name].pick(*fields)
          if fields.size == 1
            value = value.values.first
          end
          hsh[node.name] = value
          hsh
        end
      end

      #
      # Applies inherit_from! to all objects.
      #
      # 'env' specifies what environment should be for
      # each object in the list.
      #
      def inherit_from!(object_list, env)
        object_list.each do |name, object|
          if self[name]
            self[name].inherit_from!(object)
          else
            self[name] = object.duplicate(env)
          end
        end
      end

      #
      # topographical sort based on test dependency
      #
      def tsort_each_node(&block)
        self.each_key(&block)
      end

      def tsort_each_child(node_name, &block)
        if self[node_name]
          self[node_name].test_dependencies.each do |test_me_first|
            if self[test_me_first] # TODO: in the future, allow for ability to optionally pull in all dependencies.
                                   # not just the ones that pass the node filter.
              yield(test_me_first)
            end
          end
        end
      end

      def names_in_test_dependency_order
        self.tsort
      end

    end
  end
end
