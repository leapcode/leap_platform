define site_stunnel::clients (
  $accept_port,
  $connect,
  $client = true,
  $cafile,
  $key,
  $cert,
  $verify     = '2',
  $pid        = $name,
  $rndfile    = '/var/lib/stunnel4/.rnd',
  $debuglevel = '4' ) {

  $couchdb_stunnel_client_defaults = {
    'cafile'     => $ca_path,
    'key'        => $key_path,
    'cert'       => $cert_path,
  }


    stunnel::service { $name:
      accept     => "127.0.0.1:${accept_port}",
      connect    => "${connect}:6984",
      client     => $client,
      cafile     => $cafile,
      key        => $key,
      cert       => $cert,
      verify     => $verify,
      pid        => "/var/run/stunnel4/${pid}.pid",
      rndfile    => $rndfile,
      debuglevel => $debuglevel
    }
  }
