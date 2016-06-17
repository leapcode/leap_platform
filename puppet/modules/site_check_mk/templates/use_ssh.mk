# http://mathias-kettner.de/checkmk_datasource_programs.html
datasource_programs = [
<% @nagios_hosts.sort.each do |name,config| %>
 ( "ssh -o ConnectTimeout=5 -l root -i /etc/check_mk/.ssh/id_rsa -p <%=config['ssh_port']%> <%=config['domain_internal']%> check_mk_agent", [ "<%=config['domain_internal']%>" ], ),<%- end -%>

]
