define x509::key (
  $content = 'absent',
  $source  = 'absent',
  $owner   = 'root',
  $group   = 'ssl-cert'
) {
  include x509::variables
  include x509::base

  file { "${x509::variables::keys}/${name}.key":
    ensure  => file,
    mode    => '0640',
    owner   => $owner,
    group   => $group,
    require => Package['ssl-cert']
  }

  case $content {
    'absent': {
      $real_source = $source ? {
        'absent' => [
                     "puppet:///modules/site_x509/keys/${::fqdn}/${name}.key",
                     "puppet:///modules/site_x509/keys/${name}.key"
                     ],
        default => "puppet:///$source",
      }
      File["${x509::variables::keys}/${name}.key"] {
        source => $real_source
      }
    }
    default: {
      File["${x509::variables::keys}/${name}.key"] {
        content => $content
      }
    }
  }
}
