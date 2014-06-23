#
# An initial setup class. All the other classes depend on this
#
class site_couchdb::setup {

  # ensure that we don't have leftovers from previous installations
  # where we installed the cloudant bigcouch package
  # https://leap.se/code/issues/4971
  class { 'couchdb::bigcouch::package::cloudant':
    ensure => absent
  }

  $user = $site_couchdb::couchdb_admin_user

  # /etc/couchdb/couchdb-admin.netrc is deployed by couchdb::query::setup
  # we symlink to couchdb.netrc for puppet commands.
  # we symlink this to /root/.netrc for couchdb_scripts (eg. backup)
  # and makes life easier for the admin (i.e. using curl/wget without
  # passing credentials)
  file {
    '/etc/couchdb/couchdb.netrc':
      ensure  => link,
      target  => "/etc/couchdb/couchdb-${user}.netrc";

    '/root/.netrc':
      ensure  => link,
      target  => '/etc/couchdb/couchdb.netrc';

    '/srv/leap/couchdb':
      ensure => directory
  }

  couchdb::query::setup { 'localhost':
    user  => $user,
    pw    => $site_couchdb::couchdb_admin_pw,
  }

  vcsrepo { '/srv/leap/couchdb/scripts':
    ensure   => present,
    provider => git,
    source   => 'https://leap.se/git/couchdb_scripts',
    revision => 'origin/master',
    require  => File['/srv/leap/couchdb']
  }

}
