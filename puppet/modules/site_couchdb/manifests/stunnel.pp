class site_couchdb::stunnel ($key, $cert, $ca) {

  include x509::variables
  include site_stunnel

  $cert_name = 'leap_couchdb'
  $ca_name   = 'leap_ca'
  $ca_path   = "${x509::variables::local_CAs}/${ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${cert_name}.key"

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
    $ca_name:
      content => $ca,
      notify  => Service['stunnel'];
  }

  stunnel::service { 'couchdb':
    accept     => '6984',
    connect    => '127.0.0.1:5984',
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/couchdb.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4'
  }
}

