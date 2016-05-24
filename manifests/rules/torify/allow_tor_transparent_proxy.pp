class shorewall::rules::torify::allow_tor_transparent_proxy {

  $rule = "allow-tor-transparent-proxy"

  if !defined(Shorewall::Rule["$rule"]) {
    # A weirdness in shorewall forces us to explicitly allow traffic to
    # net:$tor_transparent_proxy_host:$tor_transparent_proxy_port even
    # if $FW->$FW traffic is allowed. This anyway avoids us special-casing
    # the remote Tor transparent proxy situation.
    shorewall::rule {
      "$rule":
        source          => '$FW',
        destination     => "net:${shorewall::tor_transparent_proxy_host}",
        proto           => 'tcp',
        destinationport => $shorewall::tor_transparent_proxy_port,
        order           => 100,
        action          => 'ACCEPT';
    }
  }

}
