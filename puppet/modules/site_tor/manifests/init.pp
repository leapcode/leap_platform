# generic configuration needed for tor
class site_tor {

  # Ensure the tor version is the latest from backports
  # see https://0xacab.org/leap/platform/issues/8783
  apt::preferences_snippet { 'tor':
    package  => 'tor',
    release  => "${::lsbdistcodename}-backports",
    priority => 999,
    before   => Class['tor::daemon']  }

  class { 'tor::daemon': ensure_version => latest }

}
