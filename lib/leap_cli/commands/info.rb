module LeapCli; module Commands

  desc 'Prints information regarding facts, history, and running processes for a node or nodes.'
  long_desc 'The FILTER can be the name of a node, service, or tag.'
  arg_name 'FILTER'
  command [:info] do |c|
    c.action do |global,options,args|
      nodes = manager.filter!(args)
      ssh_connect(nodes, connect_options(options)) do |ssh|
        ssh.leap.debug
      end
    end
  end

end; end
