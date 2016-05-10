#
# I am not sure about what issues might arise with DKIM key sizes
# larger than 2048. It might or might not be supported. See:
# http://dkim.org/specs/rfc4871-dkimbase.html#rfc.section.3.3.3
#
class opendkim {

  $domain_hash = hiera('domain')
  $domain      = $domain_hash['full_suffix']
  $mx          = hiera('mx')
  $dkim        = $mx['dkim']
  $selector    = $dkim['selector']
  $dkim_cert   = $dkim['public_key']
  $dkim_key    = $dkim['private_key']

  ensure_packages(['opendkim', 'libvbr2'])

  # postfix user needs to be in the opendkim group
  # in order to access the opendkim socket located at:
  # local:/var/run/opendkim/opendkim.sock
  user { 'postfix':
    groups  => 'opendkim',
    require => Package['opendkim'];
  }

  service { 'opendkim':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File[$dkim_key];
  }

  file {
    '/etc/opendkim.conf':
      ensure  => file,
      content => template('opendkim/opendkim.conf'),
      mode    => '0644',
      owner   => root,
      group   => root,
      notify  => Service['opendkim'],
      require => Package['opendkim'];

    '/etc/default/opendkim.conf':
      ensure  => file,
      content => 'SOCKET="inet:8891@localhost" # listen on loopback on port 8891',
      mode    => '0644',
      owner   => root,
      group   => root,
      notify  => Service['opendkim'],
      require => Package['opendkim'];

    $dkim_key:
      ensure  => file,
      mode    => '0600',
      owner   => 'opendkim',
      group   => 'opendkim',
      require => Package['opendkim'];

    $dkim_cert:
      ensure  => file,
      mode    => '0600',
      owner   => 'opendkim',
      group   => 'opendkim',
      require => Package['opendkim'];
  }
}
