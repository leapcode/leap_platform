class x509::base {
  include x509::variables

  package { [ 'ssl-cert', 'ca-certificates' ]:
    ensure => installed;
  }

  group { 'ssl-cert':
    ensure  => present,
    system  => true,
    require => Package['ssl-cert'];
  }

  file {
    $x509::variables::root:
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root;

    $x509::variables::keys:
      ensure  => directory,
      mode    => '0750',
      owner   => root,
      group   => ssl-cert;

    $x509::variables::certs:
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root;

    $x509::variables::local_CAs:
      ensure  => directory,
      mode    => '2775',
      owner   => root,
      group   => root;
  }

  exec { 'update-ca-certificates':
    command     => '/usr/sbin/update-ca-certificates',
    refreshonly => true,
    subscribe   => File[$x509::variables::local_CAs]
  }
}
