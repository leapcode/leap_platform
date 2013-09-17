class site_couchdb::stunnel {

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
  $ca_path   = "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${site_config::params::cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${site_config::params::cert_name}.key"

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
