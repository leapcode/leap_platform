# configure backup using couchdb-backup.py
class couchdb::backup {

  include couchdb::params

  # used in ERB templates
  $bind_address = $couchdb::params::bind_address
  $port         = $couchdb::params::port
  $backupdir    = $couchdb::params::backupdir

  file { $couchdb::params::backupdir:
    ensure  => directory,
    mode    => '0755',
    require => Package['couchdb'],
  }

  file { '/usr/local/sbin/couchdb-backup.py':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('couchdb/couchdb-backup.py.erb'),
    require => File[$couchdb::params::backupdir],
  }

  cron { 'couchdb-backup':
    command => '/usr/local/sbin/couchdb-backup.py 2> /dev/null',
    hour    => 3,
    minute  => 0,
    require => File['/usr/local/sbin/couchdb-backup.py'],
  }

  case $::operatingsystem {
    /Debian|Ubunu/: {
      # note: python-couchdb >= 0.8 required, which is found in debian wheezy.
      ensure_packages (['python-couchdb', 'python-simplejson'], {
        before => File['/usr/local/sbin/couchdb-backup.py']
      })
    }
    /RedHat|Centos/: {
      exec {'install python-couchdb using easy_install':
        command => 'easy_install http://pypi.python.org/packages/2.6/C/CouchDB/CouchDB-0.8-py2.6.egg',
        creates => '/usr/lib/python2.6/site-packages/CouchDB-0.8-py2.6.egg',
      }
    }
    default: {
      err('This module has not been written to support your operating system')
    }
  }

}
