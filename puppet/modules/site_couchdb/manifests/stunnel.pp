class site_couchdb::stunnel ($key, $cert, $ca) {

  $stunnel              = hiera('stunnel')

  $couch_server         = $stunnel['couch_server']
  $couch_server_accept  = $couch_server['accept']
  $couch_server_connect = $couch_server['connect']

  $bigcouch_replication_server         = $stunnel['bigcouch_replication_server']
  $bigcouch_replication_server_accept  = $bigcouch_replication_server['accept']
  $bigcouch_replication_server_connect = $bigcouch_replication_server['connect']

  $bigcouch_replication_clients         = $stunnel['bigcouch_replication_clients']

  include x509::variables
  $cert_name = 'leap_couchdb'
  $ca_name   = 'leap_ca'
  $ca_path   = "${x509::variables::local_CAs}/${ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${cert_name}.key"

  # basic setup: ensure cert, key, ca files are in place, and some generic
  # stunnel things are done
  class { 'site_stunnel::setup':
    cert_name => $cert_name,
    key       => $key,
    cert      => $cert,
    ca        => $ca
  }

  # setup a stunnel server for the webapp to connect to couchdb
  stunnel::service { 'couch_server':
    accept     => $couch_server_accept,
    connect    => $couch_server_connect,
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/couchserver.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4'
  }


  # setup stunnels for bigcouch clustering between each bigcouchdb node
  # server
  stunnel::service { 'bigcouch_replication_server':
    accept     => $bigcouch_replication_server_accept,
    connect    => $bigcouch_replication_server_connect,
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/bigcouchreplication_server.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4'
  }

  # clients
  $bigcouch_replication_client_defaults = {
    'client'       => true,
    'cafile'       => $ca_path,
    'key'          => $key_path,
    'cert'         => $cert_path,
  }

  create_resources(site_stunnel::clients, $bigcouch_replication_clients, $bigcouch_replication_client_defaults)
}
