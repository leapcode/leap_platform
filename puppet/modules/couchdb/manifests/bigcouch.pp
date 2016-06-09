class couchdb::bigcouch inherits couchdb::base {

  file {
    '/opt/bigcouch':
      ensure => directory,
      mode   => '0755';

    '/etc/couchdb':
      ensure => directory,
      mode   => '0755',
      before => Package['couchdb'];

    '/opt/bigcouch/etc':
      ensure => link,
      target => '/etc/couchdb',
      before => Package['couchdb'];
  }

  # there's no bigcouch in the official debian repo, you need
  # to setup a repository for that. You can use class
  # couchdb::bigcouch::package::cloudant for unauthenticated 0.4.0 packages,
  # or site_apt::leap_repo from the leap_platfrom repository
  # for signed 0.4.2 packages

  Package['couchdb'] {
    name    => 'bigcouch'
  }

  file { '/opt/bigcouch/etc/vm.args':
    content => template('couchdb/bigcouch/vm.args'),
    mode    => '0640',
    owner   => 'bigcouch',
    group   => 'bigcouch',
    require => Package['couchdb'],
    notify  => Service[couchdb]
  }

  file { '/opt/bigcouch/etc/default.ini':
    content => template('couchdb/bigcouch/default.ini'),
    mode    => '0640',
    owner   => 'bigcouch',
    group   => 'bigcouch',
    require => Package['couchdb'],
    notify  => Service[couchdb]
  }

  Service['couchdb'] {
    name     => 'bigcouch'
  }

}
