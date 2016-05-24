# installs initscript and dependent packages on debian
class couchdb::debian inherits couchdb::base {

  ensure_packages('libjs-jquery')

  file { '/etc/init.d/couchdb':
    source  => [
      'puppet:///modules/site_couchdb/Debian/couchdb',
      'puppet:///modules/couchdb/Debian/couchdb' ],
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['couchdb']
  }
}
