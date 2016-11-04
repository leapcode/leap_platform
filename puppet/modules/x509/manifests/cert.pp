define x509::cert (
  $content = 'absent',
  $source  = 'absent'
) {
  include x509::variables
  include x509::base

  file { "${x509::variables::certs}/${name}.crt":
    ensure  => file,
    mode    => '0444',
    group   => 'ssl-cert',
    require => Package['ssl-cert']
  }

  case $content {
    'absent': {
      $real_source = $source ? {
        'absent' => [
                     "puppet:///modules/site_x509/certs/${::fqdn}/${name}.crt",
                     "puppet:///modules/site_x509/certs/${name}.crt"
                     ],
        default => "puppet:///$source",
      }
      File["${x509::variables::certs}/${name}.crt"] {
        source => $real_source
      }
    }
    default: {
      File["${x509::variables::certs}/${name}.crt"] {
        content => $content
      }
    }
  }
}
