# Configures webapp couchdb config
class site_webapp::couchdb {

  $webapp                  = hiera('webapp')
  # stunnel endpoint on port localhost:4000
  $couchdb_host            = 'localhost'
  $couchdb_port            = '4000'
  $couchdb_webapp_user     = $webapp['couchdb_webapp_user']['username']
  $couchdb_webapp_password = $webapp['couchdb_webapp_user']['password']
  $couchdb_admin_user      = $webapp['couchdb_admin_user']['username']
  $couchdb_admin_password  = $webapp['couchdb_admin_user']['password']

  include x509::variables

  file {
    '/srv/leap/webapp/config/couchdb.yml':
      content => template('site_webapp/couchdb.yml.erb'),
      owner   => 'leap-webapp',
      group   => 'leap-webapp',
      mode    => '0600',
      require => Vcsrepo['/srv/leap/webapp'];

    # couchdb.admin.yml is a symlink to prevent the vcsrepo resource
    # from changing its user permissions every time.
    '/srv/leap/webapp/config/couchdb.admin.yml':
      ensure  => 'link',
      target  => '/etc/leap/couchdb.admin.yml',
      require => Vcsrepo['/srv/leap/webapp'];

    '/etc/leap/couchdb.admin.yml':
      content => template('site_webapp/couchdb.admin.yml.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      require => File['/etc/leap'];

    '/srv/leap/webapp/log':
      ensure  => directory,
      owner   => 'leap-webapp',
      group   => 'leap-webapp',
      mode    => '0755',
      require => Vcsrepo['/srv/leap/webapp'];

    '/srv/leap/webapp/log/production.log':
      ensure  => present,
      owner   => 'leap-webapp',
      group   => 'leap-webapp',
      mode    => '0666',
      require => Vcsrepo['/srv/leap/webapp'];
  }

  include site_stunnel
}
