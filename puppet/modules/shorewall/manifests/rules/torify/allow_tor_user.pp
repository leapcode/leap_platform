class shorewall::rules::torify::allow_tor_user {

  $whitelist_rule = "allow-from-tor-user"
  if !defined(Shorewall::Rule["$whitelist_rule"]) {
    shorewall::rule {
      "$whitelist_rule":
        source      => '$FW',
        destination => 'all',
        user        => $shorewall::tor_user,
        order       => 101,
        action      => 'ACCEPT';
    }
  }

}
