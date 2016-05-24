define shorewall::rules::torify::reject_non_tor(
  $user = '-',
  $originaldest = '-',
  $allow_rfc1918 = true
){

  # hash the destination as it may contain slashes
  $originaldest_sha1 = sha1($originaldest)
  $rule = "reject-non-tor-from-${user}-to=${originaldest_sha1}"

  if $originaldest == '-' {
    $originaldest_real = $allow_rfc1918 ? {
      false   => '!127.0.0.1',
      default => '!127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16',
    }
  } else {
    $originaldest_real = $originaldest
  }

  if !defined(Shorewall::Rule["$rule"]) {
    shorewall::rule {
      "$rule":
        source          => '$FW',
        destination     => 'all',
        originaldest    => $originaldest_real,
        user            => $user,
        order           => 120,
        action          => 'REJECT';
    }
  }

}
