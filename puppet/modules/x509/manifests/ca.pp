define x509::ca (
  $content = 'absent',
  $source  = 'absent'
) {
  include x509::variables
  include x509::base

  file { "${x509::variables::local_CAs}/${name}.crt" :
    ensure  => file,
    mode    => '0444',
    group   => 'ssl-cert',
    require => Package['ca-certificates'],
    notify  => Exec['update-ca-certificates'],
  }
  case $content {
    'absent': {
      $real_source = $source ? {
        'absent' => [
                     "puppet:///modules/site_x509/CAs/${::fqdn}/${name}.crt",
                     "puppet:///modules/site_x509/CAs/${name}.crt"
                     ],
        default => "puppet:///$source",
      }
      File["${x509::variables::local_CAs}/${name}.crt"] {
        source => $real_source
      }
    }
    default: {
      File["${x509::variables::local_CAs}/${name}.crt"] {
        content => $content
      }
    }
  }
}
