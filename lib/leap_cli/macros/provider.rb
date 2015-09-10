#
# These macros are intended only for use in provider.json, although they are
# currently loaded in all .json contexts.
#

module LeapCli
  module Macro

    #
    # returns an array of the service names, including only those services that
    # are enabled for this environment.
    #
    def enabled_services
      manager.env(self.environment).services[:service_type => :user_service].field(:name).select { |service|
        manager.nodes[:environment => self.environment][:services => service].any?
      }
    end

    #
    # The webapp will not work unless the service level configuration is precisely defined.
    # Here, we take what the sysadmin has specified in provider.json and clean it up to
    # ensure it is OK.
    #
    # It would be better to add support for JSON schema.
    #
    def service_levels()
      levels = {}
      provider.service.levels.each do |name, level|
        if name =~ /^[0-9]+$/
          name = name.to_i
        end
        levels[name] = level_cleanup(name, level.clone)
      end
      levels
    end

    private

    def print_warning(name, msg)
      if self.environment
        provider_str = "provider.json or %s" % ['provider', self.environment, 'json'].join('.')
      else
        provider_str = "provider.json"
      end
      LeapCli::log :warning, "In #{provider_str}, you have an incorrect definition for service level '#{name}':" do
        LeapCli::log msg
      end
    end

    def level_cleanup(name, level)
      unless level['name']
        print_warning(name, 'required field "name" is missing')
      end
      unless level['description']
        print_warning(name, 'required field "description" is missing')
      end
      unless level['bandwidth'].nil? || level['bandwidth'] == 'limited'
        print_warning(name, 'field "bandwidth" must be nil or "limited"')
      end
      unless level['rate'].nil? || level['rate'].is_a?(Hash)
        print_warning(name, 'field "rate" must be nil or a hash (e.g. {"USD":10, "EUR":10})')
      end
      possible_services = enabled_services
      if level['services']
        level['services'].each do |service|
          unless possible_services.include? service
            print_warning(name, "the service '#{service}' does not exist or there are no nodes that provide this service.")
            LeapCli::Util::bail!
          end
        end
      else
        level['services'] = possible_services
      end
      level['services'] = remap_services(level['services'])
      level
    end

    #
    # the service names that the webapp uses and that leap_platform uses are different. ugh.
    #
    SERVICE_MAP = {
      "mx" => "email",
      "openvpn" => "eip"
    }
    def remap_services(services)
      services.map {|srv| SERVICE_MAP[srv]}
    end

  end
end
