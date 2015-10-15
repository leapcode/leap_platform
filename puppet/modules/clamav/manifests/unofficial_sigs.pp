class clamav::unofficial_sigs {

  package { 'clamav-unofficial-sigs':
    ensure => installed
  }

  ensure_packages(['wget', 'gnupg', 'socat', 'rsync', 'curl'])

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
