module Leap

  class Platform
    class << self
      #
      # configuration
      #

      attr_reader :version
      attr_reader :compatible_cli
      attr_accessor :facts
      attr_accessor :paths
      attr_accessor :node_files
      attr_accessor :monitor_username
      attr_accessor :reserved_usernames

      attr_accessor :hiera_dir
      attr_accessor :hiera_path
      attr_accessor :files_dir
      attr_accessor :leap_dir
      attr_accessor :init_path

      attr_accessor :default_puppet_tags

      def define(&block)
        # some defaults:
        @reserved_usernames = []
        @hiera_dir  = '/etc/leap'
        @hiera_path = '/etc/leap/hiera.yaml'
        @leap_dir   = '/srv/leap'
        @files_dir  = '/srv/leap/files'
        @init_path  = '/srv/leap/initialized'
        @default_puppet_tags = []

        self.instance_eval(&block)

        @version ||= Gem::Version.new("0.0")
      end

      def validate!(cli_version, compatible_platforms, leapfile)
        if !compatible_with_cli?(cli_version) || !version_in_range?(compatible_platforms)
          raise StandardError, "This leap command (v#{cli_version}) " +
            "is not compatible with the platform #{leapfile.platform_directory_path} (v#{version}).\n   " +
            "You need either leap command #{compatible_cli.first} to #{compatible_cli.last} or " +
            "platform version #{compatible_platforms.first} to #{compatible_platforms.last}"
        end
      end

      def version=(version)
        @version = Gem::Version.new(version)
      end

      def compatible_cli=(range)
        @compatible_cli = range
        @minimum_cli_version = Gem::Version.new(range.first)
        @maximum_cli_version = Gem::Version.new(range.last)
      end

      #
      # return true if the cli_version is compatible with this platform.
      #
      def compatible_with_cli?(cli_version)
        cli_version = Gem::Version.new(cli_version)
        cli_version >= @minimum_cli_version && cli_version <= @maximum_cli_version
      end

      #
      # return true if the platform version is within the specified range.
      #
      def version_in_range?(range)
        if range.is_a? String
          range = range.split('..')
        end
        minimum_platform_version = Gem::Version.new(range.first)
        maximum_platform_version = Gem::Version.new(range.last)
        @version >= minimum_platform_version && @version <= maximum_platform_version
      end

      def major_version
        if @version.segments.first == 0
          @version.segments[0..1].join('.')
        else
          @version.segments.first
        end
      end

      def method_missing(method, *args)
        puts
        puts "WARNING:"
        puts "  leap_cli is out of date and does not understand `#{method}`."
        puts "  called from: #{caller.first}"
        puts "  please upgrade to a newer leap_cli"
      end

    end

  end

end