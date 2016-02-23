#
# I am not sure about what issues might arise with DKIM key sizes
# larger than 2048. It might or might not be supported. See:
# http://dkim.org/specs/rfc4871-dkimbase.html#rfc.section.3.3.3
#
class opendkim {

  $domain_hash = hiera('domain')
  $domain      = $domain_hash['full_suffix']
  $dkim        = hiera('dkim')
  $selector    = $dkim['selector']
  $dkim_key    = $dkim['private_key']

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
