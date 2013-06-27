#
# this is applied before each run of site.pp
#
$services = ''

Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }

include site_config::hosts

include site_apt

package { 'facter':
  ensure  => latest,
  require => Exec['refresh_apt']
}

