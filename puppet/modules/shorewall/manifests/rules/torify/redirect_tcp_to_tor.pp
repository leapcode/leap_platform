define shorewall::rules::torify::redirect_tcp_to_tor(
  $user = '-',
  $originaldest = '-'
){

  # hash the destination as it may contain slashes
  $originaldest_sha1 = sha1($originaldest)
  $rule = "redirect-to-tor-user=${user}-to=${originaldest_sha1}"

  if !defined(Shorewall::Rule["$rule"]) {

    $originaldest_real = $originaldest ? {
      '-'     => '!127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16',
      default => $originaldest,
    }

    $user_real = $user ? {
      '-'     => "!${shorewall::tor_user}",
      default => $user,
    }

    $destzone = $shorewall::tor_transparent_proxy_host ? {
      '127.0.0.1' => '$FW',
      default     => 'net'
    }
    
    shorewall::rule {
      "$rule":
        source       => '$FW',
        destination  => "${destzone}:${shorewall::tor_transparent_proxy_host}:${shorewall::tor_transparent_proxy_port}",
        proto        => 'tcp:syn',
        originaldest => $originaldest_real,
        user         => $user_real,
        order        => 110,
        action       => 'DNAT';
    }

  }

}
