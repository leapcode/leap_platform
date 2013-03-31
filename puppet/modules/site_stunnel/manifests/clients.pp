define site_stunnel::clients (
  $accept_port,
  $connect_port,
  $connect,
  $cafile,
  $key,
  $cert,
  $client     = true,
  $verify     = '2',
  $pid        = $name,
  $rndfile    = '/var/lib/stunnel4/.rnd',
  $debuglevel = '4' ) {

  stunnel::service { $name:
    accept     => "127.0.0.1:${accept_port}",
    connect    => "${connect}:${connect_port}",
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
