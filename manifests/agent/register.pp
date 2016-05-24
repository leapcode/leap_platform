class check_mk::agent::register (
  $host_tags = '',
  $hostname  = $::fqdn
) {
  @@check_mk::host { $hostname:
    host_tags => $host_tags,
  }
}
