#
# Provides SSH.remote_command for running commands in parallel or in sequence
# on remote servers.
#
# The gem sshkit is used for this.
#

require 'sshkit'
require 'leap_cli/ssh/options'
require 'leap_cli/ssh/backend'

SSHKit.config.backend = LeapCli::SSH::Backend
LeapCli::SSH::Backend.config.ssh_options = LeapCli::SSH::Options.global_options

#
# define remote_command
#
module LeapCli
  module SSH

    class ExecuteError < StandardError
    end

    # override default runner mode
    class CustomCoordinator < SSHKit::Coordinator
      private
      def default_options
        { in: :groups, limit: 10, wait: 0 }
      end
    end

    #
    # Available options:
    #
    #  :port -- ssh port
    #  :ip   -- ssh ip
    #  :auth_methods -- e.g. ["pubkey", "password"]
    #
    def self.remote_command(nodes, options={}, &block)
      CustomCoordinator.new(
        host_list(
          nodes,
          SSH::Options.options_from_args(options)
        )
      ).each do |ssh, host|
        LeapCli.log 2, "ssh options for #{host.hostname}: #{host.ssh_options.inspect}"
        yield ssh, host
      end
    end

    #
    # For example:
    #
    # SSH.remote_sync(nodes) do |sync, host|
    #   sync.source = '/from'
    #   sync.dest   = '/to'
    #   sync.flags  = ''
    #   sync.includes = []
    #   sync.excludes = []
    #   sync.exec
    # end
    #
    def self.remote_sync(nodes, options={}, &block)
      require 'rsync_command'
      hosts = host_list(
        nodes,
        SSH::Options.options_from_args(options)
      )
      rsync = RsyncCommand.new(:logger => LeapCli::logger)
      rsync.asynchronously(hosts) do |sync, host|
        sync.logger = LeapCli.new_logger
        sync.user   = host.user || fetch(:user, ENV['USER'])
        sync.host   = host.hostname
        sync.ssh    = SSH::Options.global_options.merge(host.ssh_options)
        sync.chdir  = Path.provider
        yield(sync, host)
      end
      if rsync.failed?
        LeapCli::Util.bail! do
          LeapCli.log :failed, "to rsync to #{rsync.failures.map{|f|f[:dest][:host]}.join(' ')}"
        end
      end
    end

    private

    def self.host_list(nodes, ssh_options_override={})
      if nodes.is_a?(Config::ObjectList)
        list = nodes.values
      elsif nodes.is_a?(Config::Node)
        list = [nodes]
      else
        raise ArgumentError, "I don't understand the type of argument `nodes`"
      end
      list.collect do |node|
        SSHKit::Host.new(
          :hostname => node.name,
          :user => 'root',
          :ssh_options => SSH::Options.node_options(node, ssh_options_override)
        )
      end
    end

  end
end


