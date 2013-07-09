define site_shorewall::couchdb::dnat (
  $source,
  $connect,
  $connect_port,
  $accept_port,
  $proto,
  $destinationport )
{


  shorewall::rule {
    "dnat_${name}_${destinationport}":
      action          => 'DNAT',
      source          => $source,
      destination     => "\$FW:127.0.0.1:${accept_port}",
      proto           => $proto,
      destinationport => $destinationport,
      originaldest    => $connect,
      order           => 200
  }
}
