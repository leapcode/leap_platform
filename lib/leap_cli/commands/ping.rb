module LeapCli; module Commands

  desc "Ping nodes to see if they are alive."
  long_desc "Attempts to ping each node in the FILTER set."
  arg_name "FILTER"
  command :ping do |c|
    c.flag 'timeout', :arg_name => "TIMEOUT",
      :default_value => 2, :desc => 'Wait at most TIMEOUT seconds.'
    c.flag 'count', :arg_name => "COUNT",
      :default_value => 2, :desc => 'Ping COUNT times.'
    c.action do |global, options, args|
      do_ping(global, options, args)
    end
  end

  private

  def do_ping(global, options, args)
    assert_bin!('ping')

    timeout = [options[:timeout].to_i, 1].max
    count   = [options[:count].to_i, 1].max
    nodes   = nil

    if args && args.any?
      node = manager.disabled_node(args.first)
      if node
        nodes = Config::ObjectList.new
        nodes.add(node.name, node)
      end
    end

    nodes ||= manager.filter! args

    threads = []
    nodes.each_node do |node|
      threads << Thread.new do
        cmd = "ping -i 0.2 -n -q -W #{timeout} -c #{count} #{node.ip_address} 2>&1"
        log(2, cmd)
        output = `#{cmd}`
        if $?.success?
          last = output.split("\n").last
          times = last.split('=').last.strip
          min, avg, max, mdev = times.split('/')
          log("ping #{min} ms", host: node.name, color: :green)
        else
          log(:failed, "to ping #{node.ip_address}", host: node.name)
        end
      end
    end
    threads.map(&:join)

    log("done")
  end

end; end


