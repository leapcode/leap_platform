module LeapCli
  class Leapfile
    attr_reader :custom_vagrant_vm_line
    attr_reader :leap_version
    attr_reader :log
    attr_reader :vagrant_basebox

    def vagrant_network
      @vagrant_network ||= '10.5.5.0/24'
    end

    private

    PRIVATE_IP_RANGES = /(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/

    def validate
      Util::assert! vagrant_network =~ PRIVATE_IP_RANGES do
        Util::log 0, :error, "in #{file}: vagrant_network is not a local private network"
      end
      return true
    end

  end
end
