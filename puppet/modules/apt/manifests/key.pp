define apt::key ($source, $ensure = 'present') {
  validate_re(
    $name, '\.gpg$',
    'An apt::key resource name must have the .gpg extension',
  )

  file {
    "/etc/apt/trusted.gpg.d/${name}":
      ensure => $ensure,
      source => $source,
      notify => Exec['apt_updated'],
  }
}
