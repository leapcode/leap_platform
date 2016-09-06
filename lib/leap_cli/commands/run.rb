module LeapCli; module Commands

  desc 'Run a shell command remotely'
  long_desc "Runs the specified command COMMAND on each node in the FILTER set. " +
            "For example, `leap run 'uname -a' webapp`"
  arg_name 'COMMAND FILTER'
  command :run do |c|
    c.switch 'stream', :default => false, :desc => 'If set, stream the output as it arrives. (default: --stream for a single node, --no-stream for multiple nodes)'
    c.flag 'port', :arg_name => 'SSH_PORT', :desc => 'Override default SSH port used when trying to connect to the server.'
    c.action do |global, options, args|
      run_shell_command(global, options, args)
    end
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


