define site_shorewall::dnat (
  $source,
  $destination,
  $proto,
  $destinationport,
  $originaldest ) {


  shorewall::rule {
    "dnat_${name}_${destinationport}":
      action          => 'DNAT',
      source          => $source,
      destination     => $destination,
      proto           => $proto,
      destinationport => $destinationport,
      originaldest    => $originaldest,
      order           => 200
  }
}
