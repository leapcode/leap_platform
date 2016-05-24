# install squid-deb-proxy-client package
class squid_deb_proxy::client {
  package { 'squid-deb-proxy-client':
    ensure => installed,
  } ->

  # ship newer client discover script than includes in squid-deb-proxy-client
  # v. 0.8.13 to fix error messages being sent to stdout instead of stderr,
  # see https://bugs.launchpad.net/ubuntu/+source/squid-deb-proxy/+bug/1505670
  file { '/usr/share/squid-deb-proxy-client/apt-avahi-discover':
    source => 'puppet:///modules/squid_deb_proxy/client/apt-avahi-discover',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
}
