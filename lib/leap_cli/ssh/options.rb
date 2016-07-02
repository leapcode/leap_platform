#
# Options for passing to the ruby gem ssh-net
#

module LeapCli
  module SSH
    module Options

      def self.global_options
        {
          #:keys_only => true,
          :global_known_hosts_file => Path.named_path(:known_hosts),
          :user_known_hosts_file => '/dev/null',
          :paranoid => true,
          :verbose => net_ssh_log_level,
          :auth_methods => ["publickey"],
          :timeout => 5
        }
      end

      def self.node_options(node, ssh_options_override=nil)
        {
          # :host_key_alias => node.name, << incompatible with ports in known_hosts
          :host_name => node.ip_address,
          :port => node.ssh.port
        }.merge(
          contingent_ssh_options_for_node(node)
        ).merge(
          ssh_options_override||{}
        )
      end

      def self.options_from_args(args)
        ssh_options = {}
        if args[:port]
          ssh_options[:port] = args[:port]
        end
        if args[:ip]
          ssh_options[:host_name] = args[:ip]
        end
        if args[:auth_methods]
          ssh_options[:auth_methods] = args[:auth_methods]
        end
        return ssh_options
      end

      def self.sanitize_command(cmd)
        if cmd =~ /(^|\/| )rm / || cmd =~ /(^|\/| )unlink /
          LeapCli.log :warning, "You probably don't want to do that. Run with --force if you are really sure."
          exit(1)
        else
          cmd
        end
      end

      private

      def self.contingent_ssh_options_for_node(node)
        opts = {}
        if node.vagrant?
          opts[:keys] = [LeapCli::Util::Vagrant.vagrant_ssh_key_file]
          opts[:keys_only] = true # only use the keys specified above, and
                                  # ignore whatever keys the ssh-agent is aware of.
          opts[:paranoid] = false # we skip host checking for vagrant nodes,
                                  # because fingerprint is different for everyone.
          if LeapCli.logger.log_level <= 1
            opts[:verbose] = :error # suppress all the warnings about adding
                                    # host keys to known_hosts, since it is
                                    # not actually doing that.
          end
        end
        if !node.supported_ssh_host_key_algorithms.empty?
          opts[:host_key] = node.supported_ssh_host_key_algorithms
        end
        return opts
      end

      def self.net_ssh_log_level
        if DEBUG
          case LeapCli.logger.log_level
            when 1 then 3
            when 2 then 2
            when 3 then 1
            else 0
          end
        else
          nil
        end
      end

    end
  end
end