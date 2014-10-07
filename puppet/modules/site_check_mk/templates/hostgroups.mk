host_groups = [
  <% @domains_internal.each do |domain| %>( '<%= domain %>', [<% @nagios_hosts.keys.sort.each do |key| -%><% if @nagios_hosts[key]['domain_internal'] == key+'.'+domain -%>'<%= key %>.<%= domain %>', <% end -%><% end -%>] ),
  <% end -%>
]
