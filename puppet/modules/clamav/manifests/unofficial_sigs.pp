class clamav::unofficial_sigs {

  package { [ 'clamav-unofficial-sigs', 'wget', 'gnupg',
              'socat', 'rsync', 'curl' ]:
    ensure => installed
  }

  file {
    '/var/log/clamav-unofficial-sigs.log':
      ensure  => file,
      owner   => clamav,
      group   => clamav,
      require => Package['clamav-unofficial-sigs'];

    '/etc/clamav-unofficial-sigs.conf.d/01-leap.conf':
      source  => 'puppet:///modules/clamav/01-leap.conf',
      mode    => '0755',
      owner   => root,
      group   => root,
      require => Package['clamav-unofficial-sigs'];
    }
}
