#
# Common commands that we would like to run on remote servers.
#
# These scripts are available via:
#
# SSH.remote_command(nodes) do |ssh, host|
#   ssh.script.custom_script_name
# end
#

module LeapCli
  module SSH
    class Scripts

      REQUIRED_PACKAGES = "puppet rsync lsb-release locales"

      attr_reader :ssh, :host
      def initialize(backend, hostname)
        @ssh = backend
        @host = hostname
      end

      #
      # creates directories that are owned by root and 700 permissions
      #
      def mkdirs(*dirs)
        raise ArgumentError.new('illegal dir name') if dirs.grep(/[\' ]/).any?
        ssh.stream dirs.collect{|dir| "mkdir -m 700 -p #{dir}; "}.join
      end

      #
      # echos "ok" if the node has been initialized and the required packages are installed, bails out otherwise.
      #
      def assert_initialized
        begin
          test_initialized_file = "test -f #{Leap::Platform.init_path}"
          check_required_packages = "! dpkg-query -W --showformat='${Status}\n' #{REQUIRED_PACKAGES} 2>&1 | grep -q -E '(deinstall|no packages)'"
          ssh.stream "#{test_initialized_file} && #{check_required_packages} && echo ok", :raise_error => true
        rescue SSH::ExecuteError
          ssh.log :error, "running deploy: node not initialized. Run `leap node init #{host}`.", :host => host
          raise # will skip further action on this node
        end
      end

      #
      # bails out the deploy if the file /etc/leap/no-deploy exists.
      #
      def check_for_no_deploy
        begin
          ssh.stream "test ! -f /etc/leap/no-deploy", :raise_error => true, :log_output => false
        rescue SSH::TimeoutError
          raise
        rescue SSH::ExecuteError
          ssh.log :warning, "can't continue because file /etc/leap/no-deploy exists", :host => host
          raise # will skip further action on this node
        end
      end

      #
      # dumps debugging information
      #
      def debug
        output = ssh.capture "#{Leap::Platform.leap_dir}/bin/debug.sh"
        ssh.log(output, :wrap => true, :host => host, :color => :cyan)
      end

      #
      # dumps the recent deploy history to the console
      #
      def history(lines)
        cmd = "(test -s /var/log/leap/deploy-summary.log && tail -n #{lines} /var/log/leap/deploy-summary.log) || (test -s /var/log/leap/deploy-summary.log.1 && tail -n #{lines} /var/log/leap/deploy-summary.log.1) || (echo 'no history')"
        history = ssh.capture(cmd, :log_output => false)
        if history
          ssh.log host, :color => :cyan, :style => :bold do
            ssh.log history, :wrap => true
          end
        end
      end

      #
      # apply puppet! weeeeeee
      #
      def puppet_apply(options)
        cmd = "#{Leap::Platform.leap_dir}/bin/puppet_command set_hostname apply #{flagize(options)}"
        ssh.stream cmd, :log_finish => true
      end

      def install_authorized_keys
        ssh.log :updating, "authorized_keys" do
          mkdirs '/root/.ssh'
          ssh.upload! LeapCli::Path.named_path(:authorized_keys), '/root/.ssh/authorized_keys', :mode => 0600
        end
      end

      #
      # for vagrant nodes, we install insecure vagrant key to authorized_keys2, since deploy
      # will overwrite authorized_keys.
      #
      # why force the insecure vagrant key?
      #   if we don't do this, then first time initialization might fail if the user has many keys
      #   (ssh will bomb out before it gets to the vagrant key).
      #   and it really doesn't make sense to ask users to pin the insecure vagrant key in their
      #   .ssh/config files.
      #
      def install_insecure_vagrant_key
        ssh.log :installing, "insecure vagrant key" do
          mkdirs '/root/.ssh'
          ssh.upload! LeapCli::Path.vagrant_ssh_pub_key_file, '/root/.ssh/authorized_keys2', :mode => 0600
        end
      end

      def install_prerequisites
        bin_dir = File.join(Leap::Platform.leap_dir, 'bin')
        node_init_path = File.join(bin_dir, 'node_init')
        ssh.log :running, "node_init script" do
          mkdirs bin_dir
          ssh.upload! LeapCli::Path.node_init_script, node_init_path, :mode => 0700
          ssh.stream node_init_path, :log_wrap => true
        end
      end

      #
      # AWS debian images only allow you to login as admin. This is done with a
      # custom command in /root/.ssh/authorized_keys, instead of by modifying
      # /etc/ssh/sshd_config.
      #
      # We need to be able to ssh as root for scp and rsync to work.
      #
      # This command is run as 'admin', with a sudo wrapper. In order for the
      # sudo to work, the command must be specified as separate arguments with
      # no spaces (that is how ssh-kit works).
      #
      def allow_root_ssh
        ssh.execute 'cp', '/home/admin/.ssh/authorized_keys', '/root/.ssh/authorized_keys'
      end

      #
      # uploads an acme challenge for renewing certificates using Let's Encrypt CA.
      #
      # Filename is returned from acme api, so it must not be trusted.
      #
      def upload_acme_challenge(filename, content)
        path = '/srv/acme/' + filename.gsub(/[^a-zA-Z0-9_-]/, '')
        ssh.upload! StringIO.new(content), path, :mode => 0444
      end

      private

      def flagize(hsh)
        hsh.inject([]) {|str, item|
          if item[1] === false
            str
          elsif item[1] === true
            str << "--" + item[0].to_s
          else
            str << "--" + item[0].to_s + " " + item[1].inspect
          end
        }.join(' ')
      end

    end
  end
end