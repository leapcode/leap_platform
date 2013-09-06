class site_couchdb::stunnel ($key, $cert, $ca) {

  $stunnel              = hiera('stunnel')

  $couch_server         = $stunnel['couch_server']
  $couch_server_accept  = $couch_server['accept']
  $couch_server_connect = $couch_server['connect']

  # Erlang Port Mapper Daemon (epmd) stunnel server/clients
  $epmd_server          = $stunnel['epmd_server']
  $epmd_server_accept   = $epmd_server['accept']
  $epmd_server_connect  = $epmd_server['connect']
  $epmd_clients         = $stunnel['epmd_clients']

  # Erlang Distributed Node Protocol (ednp) stunnel server/clients
  $ednp_server          = $stunnel['ednp_server']
  $ednp_server_accept   = $ednp_server['accept']
  $ednp_server_connect  = $ednp_server['connect']
  $ednp_clients         = $stunnel['ednp_clients']

  include x509::variables
  $cert_name = 'leap_couchdb'
  $ca_name   = 'leap_ca'
  $ca_path   = "${x509::variables::local_CAs}/${ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${cert_name}.key"

  # basic setup: ensure cert, key, ca files are in place, and some generic
  # stunnel things are done
  site_stunnel::setup { 'couchdb_couchdb':
    cert_name => $cert_name,
    key       => $key,
    cert      => $cert,
    ca_name   => $ca_name,
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


  # setup stunnel server for Erlang Port Mapper Daemon (epmd), necessary for
  # bigcouch clustering between each bigcouchdb node
  stunnel::service { 'epmd_server':
    accept     => $epmd_server_accept,
    connect    => $epmd_server_connect,
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/epmd_server.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4'
  }

  # setup stunnel clients for Erlang Port Mapper Daemon (epmd) to connect
  # to the above epmd stunnel server.
  $epmd_client_defaults = {
    'client'       => true,
    'cafile'       => $ca_path,
    'key'          => $key_path,
    'cert'         => $cert_path,
  }

  create_resources(site_stunnel::clients, $epmd_clients, $epmd_client_defaults)

  # setup stunnel server for Erlang Distributed Node Protocol (ednp), necessary
  # for bigcouch clustering between each bigcouchdb node
  stunnel::service { 'ednp_server':
    accept     => $ednp_server_accept,
    connect    => $ednp_server_connect,
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/ednp_server.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4'
  }

  # setup stunnel clients for Erlang Distributed Node Protocol (ednp) to connect
  # to the above ednp stunnel server.
  $ednp_client_defaults = {
    'client'       => true,
    'cafile'       => $ca_path,
    'key'          => $key_path,
    'cert'         => $cert_path,
  }

  create_resources(site_stunnel::clients, $ednp_clients, $ednp_client_defaults)
}
