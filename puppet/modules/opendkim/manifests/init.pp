# configure opendkim service (#5924)
class opendkim {

  $domain_hash = hiera('domain')
  $domain      = $domain_hash['full_suffix']
  $dkim        = hiera('dkim')
  $selector    = $dkim['dkim_selector']

  include site_config::x509::dkim::key
  $dkim_key    = "${x509::variables::keys}/dkim.key"

  ensure_packages(['opendkim', 'libopendkim7', 'libvbr2'])

  # postfix user needs to be in the opendkim group
  # in order to access the opendkim socket located at:
  # local:/var/run/opendkim/opendkim.sock
  user { 'postfix':
    groups => 'opendkim';
  }

  service { 'opendkim':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['Site_config::X509::Dkim::Key'],
    subscribe  => File[$dkim_key];
  }

  file { '/etc/opendkim.conf':
    ensure  => present,
    content => template('opendkim/opendkim.conf'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['opendkim'],
    require => Package['opendkim'];
}
