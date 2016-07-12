# pyzor calls out on 24441
# https://wiki.apache.org/spamassassin/NetTestFirewallIssues
class shorewall::rules::out::pyzor {
  shorewall::rule { 'me-net-udp_pyzor':
    source          => '$FW',
    destination     => 'net',
    proto           => 'udp',
    destinationport => '24441',
    order           => 240,
    action          => 'ACCEPT';
  }
}
