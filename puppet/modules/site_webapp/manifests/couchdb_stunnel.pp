class site_webapp::couchdb_stunnel ($key, $cert, $ca) {

  include x509::variables
  include site_stunnel

  $cert_name = 'leap_couchdb'
  $ca_path = "${x509::variables::certs}/leap_client_ca.crt"
  $cert_path = "${x509::variables::certs}/${cert_name}.crt"
  $key_path = "${x509::variables::keys}/${cert_name}.key"

  x509::key {
    $cert_name:
      content => $key,
      notify  => Service['stunnel'];
  }

  x509::cert {
    $cert_name:
      content => $cert,
      notify  => Service['stunnel'];
  }

  x509::ca {
    $cert_name:
      content => $ca,
      notify => Service['stunnel'];
  }

  $couchdb_stunnel_client_defaults = {
    'client'     => true,
    'cafile'     => $ca_path,
    'key'        => $key_path,
    'cert'       => $cert_path,
    'verify'     => '2',
    'rndfile'    => '/var/lib/stunnel4/.rnd',
    'debuglevel' => '4'
  }

  create_resources(site_webapp::couchdb_stunnel::clients, hiera('stunnel'), $couchdb_stunnel_client_defaults)

}

