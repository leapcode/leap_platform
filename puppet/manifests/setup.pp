#
# this is applied before each run of site.pp
#
$services = ''
include site_config::hosts

include site_apt

package { 'facter':
  ensure  => latest,
  require => Exec['refresh_apt']
}

