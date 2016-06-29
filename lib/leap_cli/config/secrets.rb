# encoding: utf-8
#
# A class for the secrets.json file
#

module LeapCli; module Config

  class Secrets < Object
    attr_reader :node_list

    def initialize(manager=nil)
      super(manager)
      @discovered_keys = {}
    end

    # we can't use fetch() or get(), since those already have special meanings
    def retrieve(key, environment)
      environment ||= 'default'
      self.fetch(environment, {})[key.to_s]
    end

    def set(*args, &block)
      if block_given?
        set_with_block(*args, &block)
      else
        set_without_block(*args)
      end
    end

    # searches over all keys matching the regexp, checking to see if the value
    # has been already used by any of them.
    def taken?(regexp, value, environment)
      self.keys.grep(regexp).each do |key|
        return true if self.retrieve(key, environment) == value
      end
      return false
    end

    def set_without_block(key, value, environment)
      set_with_block(key, environment) {value}
    end

    def set_with_block(key, environment, &block)
      environment ||= 'default'
      key = key.to_s
      @discovered_keys[environment] ||= {}
      @discovered_keys[environment][key] = true
      self[environment] ||= {}
      self[environment][key] ||= yield
    end

    #
    # if clean is true, then only secrets that have been discovered
    # during this run will be exported.
    #
    # if environment is also pinned, then we will clean those secrets
    # just for that environment.
    #
    # the clean argument should only be used when all nodes have
    # been processed, otherwise secrets that are actually in use will
    # get mistakenly removed.
    #
    def dump_json(clean=false)
      pinned_env = LeapCli.leapfile.environment
      if clean
        self.each_key do |environment|
          if pinned_env.nil? || pinned_env == environment
            env = self[environment]
            if env.nil?
              raise StandardError.new("secrets.json file seems corrupted. No such environment '#{environment}'")
            end
            env.each_key do |key|
              unless @discovered_keys[environment] && @discovered_keys[environment][key]
                self[environment].delete(key)
              end
            end
            if self[environment].empty?
              self.delete(environment)
            end
          end
        end
      end
      super()
    end
  end

end; end
