define nagios::service::dns(
  $host_name      = $::fqdn,
  $comment        = $name,
  $check_domain   = $name,
  $ip
){
  if $name != $comment {
    $check_name = "${comment}_${name}_${::hostname}"
  } else {
    $check_name = "${name}_${::hostname}"
  }

  nagios::service{
    $check_name:
      check_command       => "check_dns2!${check_domain}!${ip}",
      host_name           => $host_name,
      service_description => "check if ${::host_name} is resolving ${check_domain}";
  }
}
