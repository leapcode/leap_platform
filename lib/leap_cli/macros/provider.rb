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

  end
end
