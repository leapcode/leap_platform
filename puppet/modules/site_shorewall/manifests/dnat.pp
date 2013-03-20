define site_shorewall::dnat (
  $source,
  $destination,
  $proto,
  $destinationport,
  $originaldest ) {


  shorewall::rule {
    "dnat_${name}_${destinationport}":
      source          => $source,
      destination     => $destination,
      destinationport => $destinationport,
      originaldest    => $originaldest,
      proto           => $proto,
      order           => 200,
      action          => 'DNAT';
  }
}
