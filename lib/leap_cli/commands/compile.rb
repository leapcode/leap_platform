require 'socket'

module LeapCli
  module Commands

    desc "Compile generated files."
    command [:compile, :c] do |c|
      c.desc 'Compiles node configuration files into hiera files used for deployment.'
      c.arg_name 'ENVIRONMENT', :optional => true
      c.command :all do |all|
        all.action do |global_options,options,args|
          environment = args.first
          if !LeapCli.leapfile.environment.nil? && !environment.nil? && environment != LeapCli.leapfile.environment
            bail! "You cannot specify an ENVIRONMENT argument while the environment is pinned."
          end
          if environment
            if manager.environment_names.include?(environment)
              compile_hiera_files(manager.filter([environment]), false)
            else
              bail! "There is no environment named `#{environment}`."
            end
          else
            clean_export = LeapCli.leapfile.environment.nil?
            compile_hiera_files(manager.filter, clean_export)
          end
          if file_exists?(:static_web_readme)
            compile_provider_json(environment)
          end
        end
      end

      c.desc "Prints a DNS zone file for your provider."
      c.command :zone do |zone|
        zone.action do |global_options, options, args|
          compile_zone_file
        end
      end

      c.desc "Print entries suitable for an /etc/hosts file, useful for testing your provider."
      c.command :hosts do |hosts|
        hosts.action do |global_options, options, args|
          compile_hosts_file
        end
      end

      c.desc "Compile provider.json bootstrap files for your provider."
      c.command 'provider.json' do |provider|
        provider.action do |global_options, options, args|
          compile_provider_json
        end
      end

      c.desc "Prints a list of firewall rules. These rules are already "+
             "implemented on each node, but you might want the list of all "+
             "rules in case you also have a restrictive network firewall."
      c.command :firewall do |zone|
        zone.action do |global_options, options, args|
          compile_firewall
        end
      end

      c.default_command :all
    end

    protected

    #
    # a "clean" export of secrets will also remove keys that are no longer used,
    # but this should not be done if we are not examining all possible nodes.
    #
    def compile_hiera_files(nodes, clean_export)
      update_certificates(nodes)  # \ must come first so that output will
      update_compiled_ssh_configs # / get included in compiled hiera files.
      sanity_check(nodes)
      manager.export_nodes(nodes)
      manager.export_secrets(clean_export)
    end

    def update_compiled_ssh_configs
      generate_monitor_ssh_keys
      update_authorized_keys
      update_known_hosts
    end

    def sanity_check(nodes)
      # confirm that every node has a unique ip address
      ips = {}
      nodes.pick_fields('ip_address').each do |name, ip_address|
        if ips.key?(ip_address)
          bail! {
            log(:fatal_error, "Every node must have its own IP address.") {
              log "Nodes `#{name}` and `#{ips[ip_address]}` are both configured with `#{ip_address}`."
            }
          }
        else
          ips[ip_address] = name
        end
      end
      # confirm that the IP address of this machine is not also used for a node.
      Socket.ip_address_list.each do |addrinfo|
        if !addrinfo.ipv4_private? && ips.key?(addrinfo.ip_address)
          ip = addrinfo.ip_address
          name = ips[ip]
          bail! {
            log(:fatal_error, "Something is very wrong. The `leap` command must only be run on your sysadmin machine, not on a provider node.") {
              log "This machine has the same IP address (#{ip}) as node `#{name}`."
            }
          }
        end
      end
    end

    ##
    ## SSH
    ##

    #
    # generates a ssh key pair that is used only by remote monitors
    # to connect to nodes and run certain allowed commands.
    #
    # every node has the public monitor key added to their authorized
    # keys, and every monitor node has a copy of the private monitor key.
    #
    def generate_monitor_ssh_keys
      priv_key_file = path(:monitor_priv_key)
      pub_key_file  = path(:monitor_pub_key)
      unless file_exists?(priv_key_file, pub_key_file)
        ensure_dir(File.dirname(priv_key_file))
        ensure_dir(File.dirname(pub_key_file))
        cmd = %(ssh-keygen -N '' -C 'monitor' -t rsa -b 4096 -f '%s') % priv_key_file
        assert_run! cmd
        if file_exists?(priv_key_file, pub_key_file)
          log :created, priv_key_file
          log :created, pub_key_file
        else
          log :failed, 'to create monitor ssh keys'
        end
      end
    end

    #
    # Compiles the authorized keys file, which gets installed on every during init.
    # Afterwards, puppet installs an authorized keys file that is generated differently
    # (see authorized_keys() in macros.rb)
    #
    def update_authorized_keys
      buffer = StringIO.new
      keys = Dir.glob(path([:user_ssh, '*']))
      if keys.empty?
        bail! "You must have at least one public SSH user key configured in order to proceed. See `leap help add-user`."
      end
      if file_exists?(path(:monitor_pub_key))
        keys << path(:monitor_pub_key)
      end
      keys.sort.each do |keyfile|
        ssh_type, ssh_key = File.read(keyfile).strip.split(" ")
        buffer << ssh_type
        buffer << " "
        buffer << ssh_key
        buffer << " "
        buffer << Path.relative_path(keyfile)
        buffer << "\n"
      end
      write_file!(:authorized_keys, buffer.string)
    end

    #
    # generates the known_hosts file.
    #
    # we do a 'late' binding on the hostnames and ip part of the ssh pub key record in order to allow
    # for the possibility that the hostnames or ip has changed in the node configuration.
    #
    def update_known_hosts
      buffer = StringIO.new
      buffer << "#\n"
      buffer << "# This file is automatically generated by the command `leap`. You should NOT modify this file.\n"
      buffer << "# Instead, rerun `leap node init` on whatever node is causing SSH problems.\n"
      buffer << "#\n"
      manager.nodes.keys.sort.each do |node_name|
        node = manager.nodes[node_name]
        hostnames = [node.name, node.domain.internal, node.domain.full, node.ip_address].join(',')
        pub_key = read_file([:node_ssh_pub_key,node.name])
        if pub_key
          buffer << [hostnames, pub_key].join(' ')
          buffer << "\n"
        end
      end
      write_file!(:known_hosts, buffer.string)
    end

    ##
    ## provider.json
    ##

    #
    # generates static provider.json files that can put into place
    # (e.g. https://domain/provider.json) for the cases where the
    # webapp domain does not match the provider's domain.
    #
    def compile_provider_json(environments=nil)
      webapp_nodes = manager.nodes[:services => 'webapp']
      write_file!(:static_web_readme, STATIC_WEB_README)
      environments ||= manager.environment_names
      environments.each do |env|
        node = webapp_nodes[:environment => env].values.first
        if node
          env ||= 'default'
          write_file!(
            [:static_web_provider_json, env],
            node['definition_files']['provider']
          )
          write_file!(
            [:static_web_htaccess, env],
            HTACCESS_FILE % {:min_version => manager.env(env).provider.client_version['min']}
          )
        end
      end
    end

    HTACCESS_FILE = %[
<Files provider.json>
  Header set X-Minimum-Client-Version %{min_version}
</Files>
]

    STATIC_WEB_README = %[
This directory contains statically rendered copies of the `provider.json` file
used by the client to "bootstrap" configure itself for use with your service
provider.

There is a separate provider.json file for each environment, although you
should only need 'production/provider.json' or, if you have no environments
configured, 'default/provider.json'.

To clarify, this is the public `provider.json` file used by the client, not the
`provider.json` file that is used to configure the provider.

The provider.json file must be available at `https://domain/provider.json`
(unless this provider is included in the list of providers which are pre-
seeded in client).

This provider.json file can be served correctly in one of three ways:

(1) If the property webapp.domain is not configured, then the web app will be
    installed at https://domain/ and it will handle serving the provider.json file.

(2) If one or more nodes have the 'static' service configured for the provider's
    domain, then these 'static' nodes will correctly serve provider.json.

(3) Otherwise, you must copy the provider.json file to your web
    server and make it available at '/provider.json'. The example htaccess
    file shows what header options should be sent by the web server
    with the response.

This directory is needed for method (3), but not for methods (1) or (2).

This directory has been created by the command `leap compile provider.json`.
Once created, it will be kept up to date everytime you compile. You may safely
remove this directory if you don't use it.
]

    ##
    ##
    ## ZONE FILE
    ##

    def relative_hostname(fqdn, provider)
      @domain_regexp ||= /\.?#{Regexp.escape(provider.domain)}$/
      fqdn.sub(@domain_regexp, '')
    end

    #
    # serial is any number less than 2^32 (4294967296)
    #
    def compile_zone_file
      # note: we use the default provider for all nodes, because we use it
      # to generate hostnames that are relative to the default domain.
      provider   = manager.env('default').provider
      hosts_seen = {}
      lines      = []

      #
      # header
      #
      lines << ZONE_HEADER % {:domain => provider.domain, :ns => provider.domain, :contact => provider.contacts.default.first.sub('@','.')}

      #
      # common records
      #
      lines << ORIGIN_HEADER
      # 'A' records for primary domain
      manager.nodes[:environment => '!local'].each_node do |node|
        if node.dns['aliases'] && node.dns.aliases.include?(provider.domain)
          lines << ["@", "IN A      #{node.ip_address}"]
        end
      end
      # NS records
      if provider['dns'] && provider.dns['nameservers']
        provider.dns.nameservers.each do |ns|
          lines << ["@", "IN NS #{ns}."]
        end
      end

      # environment records
      manager.environment_names.each do |env|
        next if env == 'local'
        nodes = manager.nodes[:environment => env]
        next unless nodes.any?
        spf = nil
        dkim = nil
        lines << ENV_HEADER % (env.nil? ? 'default' : env)
        nodes.each_node do |node|
          if node.dns.public
            lines << [relative_hostname(node.domain.full, provider), "IN A      #{node.ip_address}"]
          end
          if node.dns['aliases']
            node.dns.aliases.each do |host_alias|
              if host_alias != node.domain.full && host_alias != provider.domain
                lines << [relative_hostname(host_alias, provider), "IN A      #{node.ip_address}"]
              end
            end
          end
          if node.services.include? 'mx'
            mx_domain = relative_hostname(node.domain.full_suffix, provider)
            lines << [mx_domain, "IN MX 10  #{relative_hostname(node.domain.full, provider)}"]
            spf ||= [mx_domain, spf_record(node)]
            dkim ||= dkim_record(node, provider)
          end
        end
        lines << spf if spf
        lines << dkim if dkim
      end

      # print the lines
      max_width = lines.inject(0) {|max, line| line.is_a?(Array) ? [max, line[0].length].max : max}
      lines.each do |host, line|
        if line.nil?
          puts(host)
        else
          host = '@' if host == ''
          puts("%-#{max_width}s %s" % [host, line])
        end
      end
    end

    #
    # outputs entries suitable for an /etc/hosts file
    #
    def compile_hosts_file
      manager.environment_names.each do |env|
        nodes = manager.nodes[:environment => env]
        next unless nodes.any?
        puts
        puts "## environment '#{env || 'default'}'"
        nodes.each do |name, node|
          puts "%s %s" % [
            node.ip_address,
            [name, node.get('domain.full'), node.get('dns.aliases')].compact.join(' ')
          ]
        end
      end
    end

    private

    #
    # allow mail from any mx node, plus the webapp nodes.
    #
    # TODO: ipv6
    #
    def spf_record(node)
      ips = node.nodes_like_me['services' => 'webapp'].values.collect {|n|
        "ip4:" + n.ip_address
      }
      # TXT strings may not be longer than 255 characters, although
      # you can chain multiple strings together.
      strings = "v=spf1 MX #{ips.join(' ')} -all".scan(/.{1,255}/).join('" "')
      %(IN TXT    "#{strings}")
    end

    #
    # for example:
    #
    # selector._domainkey IN TXT "v=DKIM1;h=sha256;k=rsa;s=email;p=MIGfMA0GCSq...GSIb3DQ"
    #
    # specification: http://dkim.org/specs/rfc4871-dkimbase.html#rfc.section.7.4
    #
    def dkim_record(node, provider)
      # PEM encoded public key (base64), without the ---PUBLIC KEY--- armor parts.
      assert_files_exist! :dkim_pub_key
      dkim_pub_key = Path.named_path(:dkim_pub_key)
      public_key = File.readlines(dkim_pub_key).grep(/^[^\-]+/).join

      host = relative_hostname(
        node.mx.dkim.selector + "._domainkey." + node.domain.full_suffix,
        provider)

      attrs = [
        "v=DKIM1",
        "h=sha256",
        "k=rsa",
        "s=email",
        "p=" + public_key
      ]

      return [host, "IN TXT    " + txt_wrap(attrs.join(';'))]
    end

    #
    # DNS TXT records cannot be longer than 255 characters.
    #
    # However, multiple responses will be concatenated together.
    # It looks like this:
    #
    #   IN TXT "v=spf1 .... first" "second string..."
    #
    def txt_wrap(str)
      '"' + str.scan(/.{1,255}/).join('" "') + '"'
    end

    ENV_HEADER = %[
;;
;; ENVIRONMENT %s
;;

]

    ZONE_HEADER = %[
;;
;; BIND data file for %{domain}
;;

$TTL 600
$ORIGIN %{domain}.

@ IN SOA %{ns}. %{contact}. (
  0000          ; serial
  7200          ; refresh (  24 hours)
  3600          ; retry   (   2 hours)
  1209600       ; expire  (1000 hours)
  600 )         ; minimum (   2 days)
;
]

    ORIGIN_HEADER = %[
;;
;; ZONE ORIGIN
;;

]

    ##
    ## FIREWALL
    ##

    public

    def compile_firewall
      manager.nodes.each_node(&:evaluate)

      rules = [["ALLOW TO", "PORTS", "ALLOW FROM"]]
      manager.nodes[:environment => '!local'].values.each do |node|
        next unless node['firewall']
        node.firewall.each do |name, rule|
          if rule.is_a? Hash
            rules << add_rule(rule)
          elsif rule.is_a? Array
            rule.each do |r|
              rules << add_rule(r)
            end
          end
        end
      end

      max_to    = rules.inject(0) {|max, r| [max, r[0].length].max}
      max_port  = rules.inject(0) {|max, r| [max, r[1].length].max}
      max_from  = rules.inject(0) {|max, r| [max, r[2].length].max}
      rules.each do |rule|
        puts "%-#{max_to}s   %-#{max_port}s   %-#{max_from}s" % rule
      end
    end

    private

    def add_rule(rule)
      [rule["to"], [rule["port"]].compact.join(','), rule["from"]]
    end

  end
end