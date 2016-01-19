module LeapCli; module Commands

  desc 'Output debug information.'
  long_desc 'The FILTER can be the name of a node, service, or tag.'
  arg_name 'FILTER'
  command [:debug, :d] do |c|
    c.action do |global,options,args|
      nodes = manager.filter!(args)
      ssh_connect(nodes, connect_options(options)) do |ssh|
        ssh.leap.debug
      end
    end
  end

end; end
