class couchdb::bigcouch::debian inherits couchdb::debian {

  File['/etc/init.d/couchdb'] {
    ensure => absent
  }

  file {'/etc/init.d/bigcouch':
    ensure => link,
    target => '/usr/bin/sv'
  }
}
