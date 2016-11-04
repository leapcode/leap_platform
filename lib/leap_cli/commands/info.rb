module LeapCli; module Commands

  desc 'Prints information regarding facts, history, and running processes for a node or nodes.'
  long_desc 'The FILTER can be the name of a node, service, or tag.'
  arg_name 'FILTER'
  command [:info] do |c|
    c.action do |global,options,args|
      run_info(global, options, args)
    end
  end

  private

  def run_info(global, options, args)
    require 'leap_cli/ssh'
    nodes = manager.filter!(args)
    SSH.remote_command(nodes, options) do |ssh, host|
      ssh.scripts.debug
    end
  end

end; end
