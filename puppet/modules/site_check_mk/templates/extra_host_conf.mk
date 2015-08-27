# retry 3 times before setting a host into a hard state
# and send out notification
extra_host_conf["max_check_attempts"] = [
  ("4", ALL_HOSTS )
]

# Use hostnames as alias so notification mail subjects
# are more readable and not so long. Alias defaults to
# the fqdn of a host is not changed.
extra_host_conf["alias"] = [
<% @hosts.keys.sort.each do |key| -%>  ( "<%= key.strip %>", ["<%= @hosts[key]['domain_internal']%>"]),
<% end -%>
]
