#
# Configuration class for provider.json
#

module LeapCli; module Config
  class Provider < Object
    attr_reader :environment
    def set_env(e)
      if e == 'default'
        @environment = nil
      else
        @environment = e
      end
    end
    def provider
      self
    end
    def validate!
      # nothing here yet :(
    end
  end
end; end
