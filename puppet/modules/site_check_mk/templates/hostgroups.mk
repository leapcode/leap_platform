<%
  host_groups = []
  @environments.keys.sort.each do |env_name|
    hosts = ""
    @nagios_hosts.keys.sort.each do |hostname|
      hostdata = @nagios_hosts[hostname]
      domain_internal = hostdata['domain_internal']
      if hostdata['environment'] == env_name
        hosts << '"' + domain_internal + '", '
      end
    end
    host_groups << '  ( "%s", [%s] )' % [env_name, hosts]
  end
%>
host_groups = [
<%= host_groups.join(",\n") %>
]
