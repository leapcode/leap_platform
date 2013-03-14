define site_webapp::couchdb_stunnel::clients
    ( $accept_port, $connect, $client, $cafile, $key, $cert,
      $verify, $pid = $name, $rndfile, $debuglevel ) {

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
