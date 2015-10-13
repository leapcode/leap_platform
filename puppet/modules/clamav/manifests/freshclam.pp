class clamav::freshclam {

  package { 'clamav-freshclam': ensure => installed }

  service {
    'freshclam':
      ensure     => running,
      enable     => true,
      name       => clamav-freshclam,
      pattern    => '/usr/bin/freshclam',
      hasrestart => true,
      require    => Package['clamav-freshclam'];
  }

  file_line {
    'freshclam_notify':
      path    => '/etc/clamav/freshclam.conf',
      line    => 'NotifyClamd /etc/clamav/clamd.conf',
      require => Package['clamav-freshclam'],
      notify  => Service['freshclam'];
  }

}
