class clamav::freshclam {

  package { 'clamav-freshclam': ensure => installed }

  service {
    'freshclam':
      ensure     => running,
      enable     => true,
      name       => clamav-freshclam,
      pattern    => '/usr/bin/freshclam',
      hasrestart => true;
  }

  file_line {
    'freshclam_notify':
      path   => '/etc/clamav/freshclam.conf',
      line   => 'NotifyClamd /etc/clamav/clamd.conf',
      notify => Service[freshclam];
  }

}
