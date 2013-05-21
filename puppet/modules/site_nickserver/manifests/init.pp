#
# TODO: currently, this is dependent on some things that are set up in site_webapp
#
# (1) HAProxy -> couchdb
# (2) Apache
#
# It would be good in the future to make nickserver installable independently of site_webapp.
#

class site_nickserver {
  tag 'leap_service'
  include site_config::ruby

  #
  # VARIABLES
  #

  $nickserver        = hiera('nickserver')
  $nickserver_port   = $nickserver['port']  # the port that public connects to (should be 6425)
  $nickserver_local_port = '64250'          # the port that nickserver is actually running on
  $nickserver_domain = $nickserver['domain']

  $couchdb_user      = $nickserver['couchdb_user']['username']
  $couchdb_password  = $nickserver['couchdb_user']['password']
  $couchdb_host      = 'localhost'    # couchdb is available on localhost via haproxy, which is bound to 4096.
  $couchdb_port      = '4096'         # See site_webapp/templates/haproxy_couchdb.cfg.erg

  # temporarily for now:
  $domain          = hiera('domain')
  $address_domain  = $domain['full_suffix']
  $x509            = hiera('x509')
  $x509_key        = $x509['key']
  $x509_cert       = $x509['cert']
  $x509_ca         = $x509['ca_cert']

  #
  # USER AND GROUP
  #

  group { 'nickserver':
    ensure    => present,
    allowdupe => false;
  }
  user { 'nickserver':
    ensure    => present,
    allowdupe => false,
    gid       => 'nickserver',
    home      => '/srv/leap/nickserver',
    require   => Group['nickserver'];
  }

  #
  # NICKSERVER CODE
  # NOTE: in order to support TLS, libssl-dev must be installed before EventMachine gem
  # is built/installed.
  #

  package {
    'libssl-dev': ensure => installed;
  }
  vcsrepo { '/srv/leap/nickserver':
    ensure   => present,
    revision => 'origin/master',
    provider => git,
    source   => 'git://code.leap.se/nickserver',
    owner    => 'nickserver',
    group    => 'nickserver',
    require  => [ User['nickserver'], Group['nickserver'] ],
    notify   => Exec['nickserver_bundler_update'];
  }
  exec { 'nickserver_bundler_update':
    cwd     => '/srv/leap/nickserver',
    command => '/bin/bash -c "/usr/bin/bundle check || /usr/bin/bundle install --path vendor/bundle"',
    unless  => '/usr/bin/bundle check',
    user    => 'nickserver',
    timeout => 600,
    require => [ Class['bundler::install'], Vcsrepo['/srv/leap/nickserver'], Package['libssl-dev'] ],
    notify  => Service['nickserver'];
  }

  #
  # NICKSERVER CONFIG
  #

  file { '/etc/leap/nickserver.yml':
    content => template('site_nickserver/nickserver.yml.erb'),
    owner   => nickserver,
    group   => nickserver,
    mode    => '0600',
    notify  => Service['nickserver'];
  }

  #
  # NICKSERVER DAEMON
  #

  file {
    '/usr/bin/nickserver':
      ensure  => link,
      target  => '/srv/leap/nickserver/bin/nickserver',
      require => Vcsrepo['/srv/leap/nickserver'];
    '/etc/init.d/nickserver':
      owner   => root, group => 0, mode => '0755',
      source  => '/srv/leap/nickserver/dist/debian-init-script',
      require => Vcsrepo['/srv/leap/nickserver'];
  }

  service { 'nickserver':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File['/etc/init.d/nickserver'];
  }

  #
  # FIREWALL
  # poke a hole in the firewall to allow nickserver requests
  #

  file { '/etc/shorewall/macro.nickserver':
    content => "PARAM   -       -       tcp    $nickserver_port",
    notify  => Service['shorewall'],
    require => Package['shorewall'];
  }

  shorewall::rule { 'net2fw-nickserver':
    source      => 'net',
    destination => '$FW',
    action      => 'nickserver(ACCEPT)',
    order       => 200;
  }

  #
  # APACHE REVERSE PROXY
  # nickserver doesn't speak TLS natively, let Apache handle that.
  #

  apache::module {
    'proxy': ensure => present;
    'proxy_http': ensure => present
  }

  apache::vhost::file {
    'nickserver': content => template('site_nickserver/nickserver-proxy.conf.erb')
  }

  x509::key { 'nickserver':
    content => $x509_key,
    notify  => Service[apache];
  }

  x509::cert { 'nickserver':
    content => $x509_cert,
    notify  => Service[apache];
  }

  x509::ca { 'nickserver':
    content => $x509_ca,
    notify  => Service[apache];
  }
}