#
# this is applied before each run of site.pp
#
$services = ''

Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }

include concat::setup

include site_config::hosts

include site_config::initial_firewall

include site_apt

package { 'facter':
  ensure  => latest,
  require => Exec['refresh_apt']
}

if hiera('squid_deb_proxy_client', false) {
  include site_squid_deb_proxy::client
}

