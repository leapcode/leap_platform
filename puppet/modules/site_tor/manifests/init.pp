# generic configuration needed for tor
class site_tor {

  class { 'tor::daemon': ensure_version => latest }

}
