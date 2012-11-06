class site_couchdb::package {

  # for now, we need to install couchdb from unstable,
  # because of this bug while installing:
  # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=681549
  # can be removed when couchdb/1.2.0-2 is integrated into testing
  apt::sources_list { 'unstable.list':
    source => [ 'puppet:///modules/site_apt/unstable.list'],
  }
  apt::preferences_snippet{
    'couchdb': release => 'unstable', priority => 999;
  }
}
