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
      source          => $source,
      destination     => "\$FW:127.0.0.1:${accept_port}",
      destinationport => $destinationport,
      originaldest    => $connect,
      proto           => $proto,
      order           => 200,
      action          => 'DNAT';
  }
}
