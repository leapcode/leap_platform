# monitor a host by fqdn
class nagios::target::fqdn(
  $address    = $::fqdn,
  $hostgroups = 'absent',
  $parents    = 'absent'
) {
  class{'nagios::target':
    address    => $address,
    hostgroups => $hostgroups,
    parents    => $parents
  }
}
