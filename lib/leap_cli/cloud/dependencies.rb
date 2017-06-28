#
# Ensure that the needed fog gems are installed
#
module LeapCli
  class Cloud

    SUPPORTED = {
      'aws' => {require: 'fog/aws', gem: 'fog-aws'}
    }.freeze

    def self.check_dependencies!(config)
      required_gem = map_api_to_gem(config['api'])
      if required_gem.nil?
        Util.bail! do
          Util.log :error, "The API '#{config['api']}' specified in cloud.json is not one that I know how to speak. Try one of #{supported_list}."
        end
      end

      begin
        require required_gem[:require]
      rescue LoadError
        Util.bail! do
          Util.log :error, "The 'vm' command requires the gem '#{required_gem[:gem]}'. Please run `gem install #{required_gem[:gem]}` and try again."
          Util.log "(make sure you install the gem in the ruby #{RUBY_VERSION} environment)"
        end
      end
    end

    def self.supported_list
      SUPPORTED.keys.join(', ')
    end

    def self.map_api_to_gem(api)
      SUPPORTED[api]
    end
  end
end
