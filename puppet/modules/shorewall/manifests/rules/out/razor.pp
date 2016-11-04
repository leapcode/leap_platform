# razor calls out on 2703
# https://wiki.apache.org/spamassassin/NetTestFirewallIssues
class shorewall::rules::out::razor {
  shorewall::rule { 'me-net-tcp_razor':
    source          => '$FW',
    destination     => 'net',
    proto           => 'tcp',
    destinationport => '2703',
    order           => 240,
    action          => 'ACCEPT';
  }
}
