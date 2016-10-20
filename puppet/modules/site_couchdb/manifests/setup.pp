#
# An initial setup class. All the other classes depend on this
#
class site_couchdb::setup {

  $user = $site_couchdb::couchdb_admin_user

  # setup /etc/couchdb/couchdb-admin.netrc for couchdb admin access
  couchdb::query::setup { 'localhost':
    user => $user,
    pw   => $site_couchdb::couchdb_admin_pw
  }

  # We symlink /etc/couchdb/couchdb-admin.netrc to /etc/couchdb/couchdb.netrc
  # for puppet commands, and to to /root/.netrc for couchdb_scripts
  # (eg. backup) and to makes life easier for the admin on the command line
  # (i.e. using curl/wget without passing credentials)
  file {
    '/etc/couchdb/couchdb.netrc':
      ensure => link,
      target => "/etc/couchdb/couchdb-${user}.netrc";
    '/root/.netrc':
      ensure => link,
      target => '/etc/couchdb/couchdb.netrc';
  }

  # setup /etc/couchdb/couchdb-soledad-admin.netrc file for couchdb admin
  # access, accessible only for the soledad-admin user to create soledad
  # userdbs
  if member(hiera('services', []), 'soledad') {
    file { '/etc/couchdb/couchdb-soledad-admin.netrc':
      content => "machine localhost login ${user} password ${site_couchdb::couchdb_admin_pw}",
      mode    => '0400',
      owner   => 'soledad-admin',
      group   => 'root',
      require => [ Package['couchdb'], User['soledad-admin'] ],
      notify  => Service['soledad-server'];
    }
  }

  # Checkout couchdb_scripts repo
  file {
    '/srv/leap/couchdb':
      ensure => directory
  }

  vcsrepo { '/srv/leap/couchdb/scripts':
    ensure   => present,
    provider => git,
    source   => 'https://leap.se/git/couchdb_scripts',
    revision => 'origin/master',
    require  => File['/srv/leap/couchdb']
  }

}
