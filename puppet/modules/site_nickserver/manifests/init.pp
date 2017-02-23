#
# TODO: currently, this is dependent on one thing that is set up in
# site_webapp
#
# (1) Apache
#
# It would be good in the future to make nickserver installable independently of
# site_webapp.
#

class site_nickserver {
  tag 'leap_service'
  Class['site_config::default'] -> Class['site_nickserver']

  include site_config::ruby::dev

  #
  # VARIABLES
  #

  $nickserver        = hiera('nickserver')
  $nickserver_domain = $nickserver['domain']
  $couchdb_user      = $nickserver['couchdb_nickserver_user']['username']
  $couchdb_password  = $nickserver['couchdb_nickserver_user']['password']

  # the port that public connects to (should be 6425)
  $nickserver_port   = $nickserver['port']
  # the port that nickserver is actually running on
  $nickserver_local_port = '64250'

  # couchdb is available on localhost via stunnel, which is bound to 4000.
  $couchdb_host      = 'localhost'
  $couchdb_port      = '4000'

  $sources           = hiera('sources')

  # temporarily for now:
  $domain          = hiera('domain')
  $address_domain  = $domain['full_suffix']

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca

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

  # Eariler we used bundle install without --deployment
  exec { 'clean_git_repo':
    cwd     => '/srv/leap/nickserver',
    user    => 'nickserver',
    command => '/usr/bin/git checkout Gemfile.lock',
    onlyif  => '/usr/bin/git status | /bin/grep -q "modified: *Gemfile.lock"',
    require => Package['git']
  }

  vcsrepo { '/srv/leap/nickserver':
    ensure   => latest,
    revision => $sources['nickserver']['revision'],
    provider => $sources['nickserver']['type'],
    source   => $sources['nickserver']['source'],
    owner    => 'nickserver',
    group    => 'nickserver',
    require  => [ User['nickserver'], Group['nickserver'], Exec['clean_git_repo'] ],
    notify   => Exec['nickserver_bundler_update'];
  }

  exec { 'nickserver_bundler_update':
    cwd     => '/srv/leap/nickserver',
    command => '/usr/bin/bundle install --deployment',
    unless  => '/bin/bash -c "/usr/bin/bundle config --local frozen 1; /usr/bin/bundle check"',
    user    => 'nickserver',
    timeout => 600,
    require => [
      Class['bundler::install'], Vcsrepo['/srv/leap/nickserver'],
      Package['libssl-dev'], Class['site_config::ruby::dev'] ],

    notify  => Service['nickserver'];
  }

  #
  # NICKSERVER CONFIG
  #

  file { '/etc/nickserver.yml':
    content => template('site_nickserver/nickserver.yml.erb'),
    owner   => nickserver,
    group   => nickserver,
    mode    => '0600',
    notify  => Service['nickserver'];
  }

  #
  # NICKSERVER DAEMON
  #

  file { '/usr/bin/nickserver':
    ensure  => link,
    target  => '/srv/leap/nickserver/bin/nickserver',
    require => Vcsrepo['/srv/leap/nickserver'];
  }

  ::systemd::unit_file {'nickserver.service':
    ensure    => present,
    source    => '/srv/leap/nickserver/dist/nickserver.service',
    subscribe => Vcsrepo['/srv/leap/nickserver'],
    require   => File['/usr/bin/nickserver'];
  }

  service { 'nickserver':
    ensure   => running,
    provider => 'systemd',
    enable   => true,
    require  => [
      Systemd::Unit_file['nickserver.service'],
      Exec['systemctl-daemon-reload'],
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Ca'] ];
  }

  #
  # FIREWALL
  # poke a hole in the firewall to allow nickserver requests
  #

  file { '/etc/shorewall/macro.nickserver':
    content => "PARAM   -       -       tcp    ${nickserver_port}",
    notify  => Exec['shorewall_check'],
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
    'nickserver':
      content => template('site_nickserver/nickserver-proxy.conf.erb')
  }

}
