# setup repository for tor
class tor::repo (
  $ensure      = present,
  $source_name = 'torproject.org',
  $include_src = false,
) {
  case $::osfamily {
    'Debian': {
      $key      = '886DDD89'
      $location = 'https://deb.torproject.org/torproject.org/'
      class { 'tor::repo::debian': }
    }
    default: {
      fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports managing repos for osfamily Debian and Ubuntu") # lint:ignore:80chars
    }
  }
}
