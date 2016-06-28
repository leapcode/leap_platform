module LeapCli
  module Commands

    desc 'Opens useful URLs in a web browser.'
    long_desc "NAME can be one or more of: monitor, web, docs, bug"
    arg_name 'NAME'
    command :open do |c|
      c.flag :env, :desc => 'Which environment to use (optional).', :arg_name => 'ENVIRONMENT'
      c.switch :ip, :desc => 'To get around HSTS or DNS, open the URL using the IP address instead of the domain (optional).'
      c.action do |global_options,options,args|
        do_open_cmd(global_options, options, args)
      end
    end

    private

    def do_open_cmd(global, options, args)
      env = options[:env] || LeapCli.leapfile.environment
      args.each do |name|
        if name == 'monitor' || name == 'nagios'
          open_nagios(env, options[:ip])
        elsif name == 'web' || name == 'webapp'
          open_webapp(env, options[:ip])
        elsif name == 'docs' || name == 'help' || name == 'doc'
          open_url("https://leap.se/docs")
        elsif name == 'bug' || name == 'feature' || name == 'bugreport'
          open_url("https://leap.se/code")
        else
          bail! "'#{name}' is not a recognized URL."
        end
      end
    end

    def find_node_with_service(service, environment)
      nodes = manager.nodes[:services => service]
      node = nil
      if nodes.size == 0
        bail! "No nodes with '#{service}' service."
      elsif nodes.size == 1
        node = nodes.values.first
      elsif nodes.size > 1
        if environment
          node = nodes[:environment => environment].values.first
          if node.nil?
            bail! "No nodes with '#{service}' service."
          end
        else
          node_list = nodes.values
          list = node_list.map {|i| "#{i.name} (#{i.environment})"}
          index = numbered_choice_menu("Which #{service}?", list) do |line, i|
            say("#{i+1}. #{line}")
          end
          node = node_list[index]
        end
      end
      return node
    end

    def pick_domain(node, ip)
      bail! "monitor missing webapp service" unless node["webapp"]
      if ip
        domain = node["ip_address"]
      else
        domain = node["webapp"]["domain"]
        bail! "webapp domain is missing" unless !domain.empty?
      end
      return domain
    end

    def open_webapp(environment, ip)
      node = find_node_with_service('webapp', environment)
      domain = pick_domain(node, ip)
      open_url("https://%s" % domain)
    end

    def open_nagios(environment, ip)
      node = find_node_with_service('monitor', environment)
      domain = pick_domain(node, ip)
      username = 'nagiosadmin'
      password = manager.secrets.retrieve("nagios_admin_password", node.environment)
      bail! "unable to find nagios_admin_password" unless !password.nil? && !password.empty?
      open_url("https://%s:%s@%s/nagios3" % [username, password, domain])
    end

    def open_url(url)
      log :opening, url
      if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
        system %(start "#{url}")
      elsif RbConfig::CONFIG['host_os'] =~ /darwin/
        system %(open "#{url}")
      elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
        ['xdg-open', 'sensible-browser', 'gnome-open', 'kde-open'].each do |cmd|
          if !`which #{cmd}`.strip.empty?
            system %(#{cmd} "#{url}")
            return
          end
        end
        log :error, 'no command found to launch browser window.'
      end
    end

  end
end