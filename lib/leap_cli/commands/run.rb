module LeapCli; module Commands

  desc 'Run a shell command remotely'
  long_desc "Runs the specified command COMMAND on each node in the FILTER set. " +
            "For example, `leap run 'uname -a' webapp`"
  command :run do |c|
    c.switch 'stream', :default => false, :desc => 'If set, stream the output as it arrives. (default: --stream for a single node, --no-stream for multiple nodes)'
    c.flag 'port', :arg_name => 'SSH_PORT', :desc => 'Override default SSH port used when trying to connect to the server.'

    c.desc 'Run an arbitrary shell command.'
    c.arg_name 'FILTER', optional: true
    c.command :command do |command|
      command.action do |global, options, args|
        run_shell_command(global, options, args)
      end
    end

    c.desc 'Generate one or more new invite codes.'
    c.arg_name '[COUNT] [ENVIRONMENT]'
    c.command :invite do |invite|
      invite.action do |global_options,options,args|
        run_new_invites(global_options, options, args)
      end
    end

    c.default_command :command
  end

  private

  def run_shell_command(global, options, args)
    require 'leap_cli/ssh'
    cmd    = args[0]
    filter = args[1..-1]
    cmd    = global[:force] ? cmd : LeapCli::SSH::Options.sanitize_command(cmd)
    nodes  = manager.filter!(filter)
    if nodes.size == 1 || options[:stream]
      stream_command(nodes, cmd, options)
    else
      capture_command(nodes, cmd, options)
    end
  end

  CMD_NEW_INVITES="cd /srv/leap/webapp; RAILS_ENV=production bundle exec rake \"generate_invites[NUM,USES]\""

  def run_new_invites(global, options, args)
    require 'leap_cli/ssh'
    count = 1
    uses  = 1
    env   = nil
    arg1  = args.shift
    arg2  = args.shift
    if arg1 && arg2
      env   = manager.env(arg2)
      count = arg1
    elsif arg1
      env = manager.env(arg1)
    else
      env = manager.env(nil)
    end
    unless env
      bail! "Environment name you specified does not match one that is available. See `leap env ls` for the available names"
    end

    env_name = env.name == 'default' ? nil : env.name
    webapp_nodes = env.nodes[:environment => env_name][:services => 'webapp'].first
    if webapp_nodes.empty?
      bail! "Could not find a webapp node for the specified environment"
    end
    stream_command(
      webapp_nodes,
      CMD_NEW_INVITES.sub('NUM', count.to_s).sub('USES', uses.to_s),
      options
    )
  end

  def capture_command(nodes, cmd, options)
    SSH.remote_command(nodes, options) do |ssh, host|
      output = ssh.capture(cmd, :log_output => false)
      if output
        logger = LeapCli.new_logger
        logger.log(:ran, "`" + cmd + "`", host: host.hostname, color: :green) do
          logger.log(output, wrap: true)
        end
      end
    end
  end

  def stream_command(nodes, cmd, options)
    SSH.remote_command(nodes, options) do |ssh, host|
      ssh.stream(cmd, :log_cmd => true, :log_finish => true, :fail_msg => 'oops')
    end
  end

end; end


