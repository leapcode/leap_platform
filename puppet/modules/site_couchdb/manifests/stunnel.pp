class site_couchdb::stunnel ($key, $cert, $ca) {

  include x509::variables

  $cert_name = 'leap_couchdb'
  $ca_name   = 'leap_ca'
  $ca_path   = "${x509::variables::local_CAs}/${ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${cert_name}.key"

  class { 'site_stunnel::setup':
    cert_name => $cert_name,
    key       => $key,
    cert      => $cert,
    ca        => $ca
  }

  # webapp access
  stunnel::service { 'couchdb':
    accept     => '6984',
    connect    => '127.0.0.1:5984',
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/bigcouch.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4'
  }

  # clustering between bigcouch nodes

  # server
  stunnel::service { 'bigcouch':
    accept     => '5369',
    connect    => '127.0.0.1:4369',
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/couchdb.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4'
  }

  # clients
  $couchdb_stunnel_client_defaults = {
    'connect_port' => '5369',
    'client'       => true,
    'cafile'       => $ca_path,
    'key'          => $key_path,
    'cert'         => $cert_path,
  }
  create_resources(site_stunnel::clients, hiera('stunnel'), $couchdb_stunnel_client_defaults)

}

